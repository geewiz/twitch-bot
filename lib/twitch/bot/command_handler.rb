# frozen_string_literal: true

module Twitch
  module Bot
    # Base class for implementing chat commands
    class CommandHandler < EventHandler
      def self.handled_events
        [:user_message]
      end

      def command_aliases
        []
      end

      # FIXME: Does this have to be public only for testing?
      def call
        if event.command? && command_aliases.include?(event.command)
          handle_command
        end
      end

      private

      def handle_command
        raise NotImplementedError
      end
    end
  end
end
