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
          Message::NotSupported.new(irc_message)
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
        Message::Ping.new(hostname: message.params.last)
      end
    end

    # Parses a PRIVMSG IRC command
    class PrivMsgCommandParser < CommandParser
      def call
        user = message.user
        text = message.text
        if user == "twitchnotify"
          if text.match?(/just subscribed!/)
            Message::Subscription.new(
              user: message.params.last.split(" ").first,
            )
          else
            Message::NotSupported.new(message)
          end
        else
          Message::UserMessage.new(text: text, user: user)
        end
      end
    end

    # Parses a MODE IRC command
    class ModeCommandParser < CommandParser
      MODE_CHANGE = {
        "-o" => :remove_moderator,
        "+o" => :add_moderator,
      }.freeze

      def call
        params = message.params
        Message::Mode.new(user: params.last, mode: MODE_CHANGE[params[1]])
      end
    end

    # Parses a 372 IRC status code/command.
    class AuthenticatedCommandParser < CommandParser
      def call
        Message::Authenticated.new
      end
    end

    # Parses a 366 IRC status code/command.
    class JoinCommandParser < CommandParser
      def call
        Message::Join.new
      end
    end

    # Parses a ROOMSTATE IRC command.
    class RoomStateCommandParser < CommandParser
      def call
        roomstate_tags = {
          "slow" => SlowModeParser,
          "followers-only" => FollowersOnlyModeParser,
          "subs-only" => SubsOnlyModeParser,
          "r9k" => R9kModeParser,
        }

        roomstate_tags.each do |tag, parser|
          if message.tags.include?(tag)
            return parser.new(message).call
          end
        end

        Message::NotSupported.new(message)
      end
    end

    class SlowModeParser < CommandParser
      def call
        Message::SlowMode.new(
          status: message.tags["slow"],
          channel: message.channel,
        )
      end
    end

    class FollowersOnlyModeParser < CommandParser
      def call
        Message::FollowersOnlyMode.new(
          status: message.tags["followers-only"],
        )
      end
    end

    class SubsOnlyModeParser < CommandParser
      def call
        Message::SubsOnlyMode.new(
          status: message.tags["subs-only"],
          channel: message.channel,
        )
      end
    end

    class R9kModeParser < CommandParser
      def call
        Message::R9kMode.new(
          status: message.tags["r9k"],
          channel: message.channel,
        )
      end
    end

    # Parses a NOTICE IRC command.
    class NoticeCommandParser < CommandParser
      def call
        if message.params.last.match?(/Login authentication failed/) ||
          message.params.last.match?(/Login unsuccessful/)
          Message::LoginFailed.new(user: message.user)
        else
          Message::NotSupported.new(message)
        end
      end
    end
  end
end
