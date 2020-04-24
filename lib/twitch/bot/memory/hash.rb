# frozen_string_literal: true

module Twitch
  module Bot
    # Manage a key/value store for our bot
    module Memory
      class Hash
        def initialize
          @kvstore = {}
        end

        def store(key, value)
          kvstore[key] = value
        end

        def retrieve(key)
          kvstore[key]
        end

        private

        attr_reader :kvstore
      end
    end
  end
end
