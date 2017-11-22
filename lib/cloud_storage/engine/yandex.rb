module CloudStorage
  module Engine
    # YandexDisk engine
    class Yandex < StorageEngine
      URL_API = 'https://cloud-api.yandex.net/v1/disk'.freeze

      # ls path
      def ls(path)
        response = request(:get, "/v1/disk/resources?path=app:#{path}&limit=1000")
        if response.key?('error')
          []
        else
          response['_embedded']['items'].collect do |item|
            case item['type']
            when 'dir' then
              folder_item(item)
            when 'file' then
              file_item(item)
            end
          end
        end
      end

      # folder
      def folder_item(item)
        CloudStorage::Item.new(type: :folder,
                               name: item['name'],
                               path: item['path'],
                               created: Time.parse(item['created']),
                               modified: Time.parse(item['modified']))
      end

      # file
      def file_item(item)
        CloudStorage::Item.new(type: :file,
                               name: item['name'],
                               path: item['path'],
                               created: Time.parse(item['created']),
                               modified: Time.parse(item['modified']),
                               mime_type: item['mime_type'],
                               md5: item['md5'])
      end

      # exists? path
      def exists?(path)
        response = request(:get, "/v1/disk/resources?path=app:#{path}&fields=name")
        !(response.key?('error') && response['error'] == 'DiskNotFoundError')
      end

      def mkdir(path)
        response = request(:put, "/v1/disk/resources?path=app:#{path}")
        response.key?('href')
      end

      def rm(path)
        response = request(:delete, "/v1/disk/resources?path=app:#{path}")
        response == {}
      end

      def upload(file, path)
        params = request(:get, "/v1/disk/resources/upload?path=app:#{path}&overwrite=true")
        response = upload_request(file, path.split('/').last, params['href']) if params['href'].present?
        true
      end

      def info
        response = request(:get, "/v1/disk/")
        { total_space: response['total_space'], used_space: response['used_space'], trash_size: response['trash_size'] }
      end

      private

      # request
      def request(method, path)
        headers = { 'Authorization' => "OAuth #{@config[:token]}", 'Content-Type' => 'application/json' }
        response = case method.to_sym
                   when :put, :post then connection(URL_API).send(method.to_sym, path, nil, headers)
                   when :delete, :get then connection(URL_API).send(method.to_sym, path, headers)
                   end
        if [Net::HTTPOK, Net::HTTPCreated, Net::HTTPNotFound].include?(response.class)
          JSON.parse(response.body)
        else
          {}
        end
      end

      # upload
      def upload_request(stream, filename, url)
        uri = URI.parse(url)
        connection = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == "https"
          connection.use_ssl = true
          connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        request = Net::HTTP::Post.new uri
        boundary = "RubyClient#{rand(999999)}"
        body = []
        body << "------#{boundary}"
        body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{filename}\""
        body << 'Content-Type: text/plain'
        body << ''
        body << stream.read
        body << "------#{boundary}--"
        request.body = body.join("\r\n")
        request.content_type = "multipart/form-data; boundary=----#{boundary}"
        response = connection.request(request)
        unless response.kind_of? Net::HTTPCreated
          raise RuntimeError.new "#{response.body}"
        end
        true
      end
    end
  end
end
