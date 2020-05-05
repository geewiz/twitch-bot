# frozen_string_literal: true

module Twitch
  module Bot
    # Base class for implementing chat commands
    class CommandHandler < EventHandler
      def initialize(event:, client:)
        super
        @command_aliases = []
      end

      def call
        if event.command? && command_aliases.include?(event.command)
          handle_command
        end
      end

      def command_alias(command_alias)
        @command_aliases << command_alias
      end

      private

      attr_reader :command_aliases

      def handle_command
        raise NotImplementedError
      end
    end
  end
end
