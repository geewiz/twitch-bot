# frozen_string_literal: true

module Twitch
  module Bot
    # Manage a key/value store for our bot
    module Memory
      # Implement an ephemeral memory using a Hash
      class Hash
        def initialize(client:)
          @client = client
          @kvstore = {}
        end

        def store(key, value)
          kvstore[key] = value
        end

        def retrieve(key)
          kvstore[key]
        end

        private

        attr_reader :client, :kvstore
      end
    end
  end
end
