module CloudStorage
  module Engine
    # base engine class
    class StorageEngine
      attr_accessor :config

      # initialize
      def initialize(config)
        @config = config
      end

      # http connection
      def connection(url)
        return @connection if defined? @connection
        uri = URI.parse(url)
        @connection = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          @connection.use_ssl = true
          @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        @connection
      end
    end
  end
end
