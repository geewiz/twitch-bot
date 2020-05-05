# frozen_string_literal: true

require "redis"

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
          redis.set(key, value)
        end

        def retrieve(key)
          redis.get(key)
        end

        private

        attr_reader :client, :redis

        def connect_db
          url = redis_config_url || ENV["REDIS_URL"]
          ::Redis.new(url: url)
        end

        def redis_config_url
          config = client.config
          if config.setting("redis_host")
            host = config.setting("redis_host") || "localhost"
            port = config.setting("redis_port") || 6379
            "redis://#{host}:#{port}"
          end
        end
      end
    end
  end
end
