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
    end
  end
end
