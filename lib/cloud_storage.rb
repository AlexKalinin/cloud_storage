require 'net/http'
require 'net/https'
require 'openssl'
require 'json'
require 'time'

require 'cloud_storage/version'
require_relative 'cloud_storage/engine/storage_engine'
require_relative 'cloud_storage/engine/yandex'
require_relative 'cloud_storage/engine/dropbox'

module CloudStorage
  # storage item
  class Item
    attr_accessor :type, :name, :path, :size, :created, :modified, :mime_type, :md5, :media_type
    # initialize
    def initialize(**args)
      args.each do |key, value|
        send("#{key}=", value)
      end
    end
  end
  # storage factory
  class StorageFactory
    # builder
    def self.build(engine_type, *args)
      case engine_type
      when :yandex
        Engine::Yandex.new(*args)
      when :dropbox
        Engine::Dropbox.new(*args)
      end
    end
  end
end
