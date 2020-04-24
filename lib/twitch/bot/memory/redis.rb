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
          config = client.config
          host = config.setting("redis_host") ||
            ENV["REDIS_HOST"] || "localhost"
          port = config.setting("redis_port") ||
            ENV["REDIS_PORT"] || 6379
          ::Redis.new(host: host, port: port)
        end
      end
    end
  end
end
