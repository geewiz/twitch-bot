# frozen_string_literal: true

require "redis"
require "json"

module Twitch
  module Bot
    module Memory
      # Implement persistent memory based on Redis
      class Redis
        def initialize(client:)
          @client = client
          @redis = connect_db
        end

        def store(key, value)
          redis.set(key, value.to_json)
        end

        def retrieve(key)
          value = redis.get(key)
          value.nil? ? nil : JSON.parse(value)
        end

        private

        attr_reader :client, :redis

        def connect_db
          url = ENV["REDIS_URL"] || redis_config_url
          ::Redis.new(url: url)
        end

        def redis_config_url
          config = client.config
          host = config.setting("redis_host") || "localhost"
          port = config.setting("redis_port") || 6379
          "redis://#{host}:#{port}"
        end
      end
    end
  end
end
