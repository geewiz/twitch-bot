# frozen_string_literal: true

module Twitch
  module Bot
    # Represent a generic Twitch chat event/message
    class Event
      attr_reader :type

      def initialize(type: :unknown)
        @type = type
      end
    end
  end
end
