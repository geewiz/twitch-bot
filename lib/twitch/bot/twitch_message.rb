# frozen_string_literal: true

# TODO: Use namespace

module Twitch
  module Bot
    # This class is the abstract base class for IRC events.
    class TwitchMessage < Twitch::Bot::Event
      def initialize(_message)
        @type = :unknown
      end
    end

    # This class represents an event that is not supported.
    class NotSupportedMessage < TwitchMessage
      attr_reader :message

      def initialize(message)
        @message = message
        @type = :not_supported
      end
    end

    # This class stores the details of a Ping event.
    class PingMessage < TwitchMessage
      attr_reader :hostname, :user

      def initialize(message)
        @user = message.user
        @hostname = message.params.last
        @type = :ping
      end
    end

    # This class stores the details of a Mode event.
    class ModeMessage < TwitchMessage
      attr_reader :user, :mode

      MODE_CHANGE = {
        "+o" => :add_moderator,
        "-o" => :remove_moderator,
      }.freeze
      def initialize(message)
        params = message.params
        @user = params.last
        @mode = MODE_CHANGE[params[1]]
        @type = :mode
      end
    end

    # This class stores the details of an Authenticated event.
    class AuthenticatedMessage < TwitchMessage
      def initialize(_message)
        @type = :authenticated
      end
    end

    # This class stores the details of a Join event.
    class JoinMessage < TwitchMessage
      def initialize(_message)
        @type = :join
      end
    end

    # This class stores the details of a Subscription event.
    class SubscriptionMessage < TwitchMessage
      attr_reader :user

      def initialize(message)
        @user = message.params.last.split(" ").first
        @type = :subscription
      end
    end

    # This class stores the details of a ChatMessage event.
    class ChatMessageMessage < TwitchMessage
      attr_reader :text, :user

      def initialize(text:, user:)
        @text = text
        @user = user
        @type = :chat_message
      end

      def bot_command?(command)
        text.split(/\s+/).first.match?(/^!#{command}/)
      end
    end

    # This class stores the details of a LoginFailed event.
    class LoginFailedMessage < TwitchMessage
      attr_reader :user

      def initialize(message)
        @user = message.user
        @type = :login_failed
      end
    end

    # This class stores the details of a SlowMode event.
    class SlowModeMessage < TwitchMessage
      attr_reader :status, :channel

      def initialize(message)
        @status = message.tags["slow"]
        @channel = message.channel
        @type = :slow_mode
      end

      def enabled?
        status.to_i.positive?
      end
    end

    # This class stores the details of a FollowersOnlyMode event.
    class FollowersOnlyModeMessage < TwitchMessage
      attr_reader :status

      def initialize(message)
        @status = message.tags["followers-only"]
        @type = :followers_only_mode
      end
    end

    # This class stores the details of a SubsOnlyMode event.
    class SubsOnlyModeMessage < TwitchMessage
      attr_reader :status, :channel

      def initialize(message)
        @status = message.tags["subs-only"]
        @channel = message.channel
        @type = :subs_only_mode
      end
    end

    # This class stores the details of a R9kMode event.
    class R9kModeMessage < TwitchMessage
      attr_reader :status, :channel

      def initialize(message)
        @status = message.tags["r9k"]
        @channel = message.channel
        @type = :r9k_mode
      end
    end
  end
end
