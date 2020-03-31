# frozen_string_literal: true

module Twitch
  module Bot
    # Handles a message of a specific type
    class EventHandler
      attr_reader :event, :client

      def initialize(event:, client:)
        @event = event
        @client = client
      end

      #
      # Handle the event
      #
      # @return void
      #
      def call
        raise "Unhandled #{event.type}"
      end

      #
      # Return a list of event types this handler can handle
      #
      # @return [Array] event type list
      #
      def self.handled_events
        []
      end
    end
  end
end
