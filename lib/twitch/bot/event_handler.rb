# frozen_string_literal: true

module Twitch
  module Bot
    # Handles a message of a specific type
    class EventHandler
      attr_reader :event, :client

      #
      # Return a list of event types this handler subscribes to
      #
      # @return [Array] list of event types
      #
      def self.handled_events
        []
      end

      #
      # Inititalize an event handler object
      #
      # @parameter event The latest event of a subscribed type
      # @parameter client The current chat client object
      #
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
    end
  end
end
