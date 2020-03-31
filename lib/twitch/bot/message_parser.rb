# frozen_string_literal: true

module Twitch
  module Bot
    # This class calls the parser related to the IRC command we received.
    class MessageParser
      def initialize(irc_message)
        @irc_message = irc_message
      end

      def message
        parse_command
      end

      private

      attr_reader :irc_message

      def parse_command
        command_parser = {
          "MODE" => ModeCommandParser,
          "PING" => PingCommandParser,
          "372" => AuthenticatedCommandParser,
          "366" => JoinCommandParser,
          "PRIVMSG" => PrivMsgCommandParser,
          "ROOMSTATE" => RoomStateCommandParser,
          "NOTICE" => NoticeCommandParser,
        }
        parser = command_parser[irc_message.command]
        if parser
          parser.new(irc_message).call
        else
          NotSupportedMessage.new(irc_message)
        end
      end
    end

    # Abstract base class for a parser for a specific IRC command.
    class CommandParser
      attr_reader :message

      def initialize(message)
        @message = message
      end
    end

    # Parses a PING IRC command
    class PingCommandParser < CommandParser
      def call
        PingMessage.new(message)
      end
    end

    # Parses a PRIVMSG IRC command
    class PrivMsgCommandParser < CommandParser
      def call
        if message.user == "twitchnotify"
          if message.text.match?(/just subscribed!/)
            SubscriptionMessage.new(message)
          else
            NotSupportedMessage.new(message)
          end
        else
          ChatMessageMessage.new(message)
        end
      end
    end

    # Parses a MODE IRC command
    class ModeCommandParser < CommandParser
      def call
        ModeMessage.new(message)
      end
    end

    # Parses a 372 IRC status code/command.
    class AuthenticatedCommandParser < CommandParser
      def call
        AuthenticatedMessage.new(message)
      end
    end

    # Parses a 366 IRC status code/command.
    class JoinCommandParser < CommandParser
      def call
        JoinMessage.new(message)
      end
    end

    # Parses a ROOMSTATE IRC command.
    class RoomStateCommandParser < CommandParser
      def call
        roomstate_tags = {
          "slow" => SlowModeMessage,
          "followers-only" => FollowersOnlyModeMessage,
          "subs-only" => SubsOnlyModeMessage,
          "r9k" => R9kModeMessage,
        }

        roomstate_tags.each do |tag, event|
          if message.tags.include?(tag)
            return event.new(message)
          end
        end

        NotSupportedMessage.new(message)
      end
    end

    # Parses a NOTICE IRC command.
    class NoticeCommandParser < CommandParser
      def call
        if message.params.last.match?(/Login authentication failed/)
          LoginFailedMessage.new(message)
        else
          NotSupportedMessage.new(message)
        end
      end
    end
  end
end
