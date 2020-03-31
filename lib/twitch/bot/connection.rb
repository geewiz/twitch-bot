# frozen_string_literal: true

module Twitch
  module Bot
    # This class stores the connection details for the client.
    class Connection
      attr_reader :nickname, :password, :hostname, :port

      def initialize(
        nickname:, password:, hostname: "irc.chat.twitch.tv", port: "6667"
      )
        @nickname = nickname
        @password = password
        @hostname = hostname
        @port = port
      end
    end
  end
end
