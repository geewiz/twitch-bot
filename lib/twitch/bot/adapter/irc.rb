# frozen_string_literal: true

require "socket"

module Twitch
  module Bot
    module Adapter
      # Handle the bot's IRC connection
      class Irc
        def initialize(client:)
          @client = client

          open_socket
        end

        def connect
          enable_twitch_capabilities
          authenticate
        end

        def shutdown
          close_socket
        end

        def read_data
          raw_message = read_data_from_socket
          irc_message = IrcMessage.new(raw_message)
          Twitch::Bot::MessageParser.new(irc_message).message
        end

        def send_message(text)
          privmsg = "PRIVMSG ##{channel.name} :#{text}"
          send_data(privmsg)
        end

        def send_data(data)
          send_data_to_socket(data)
        end

        def join_channel(channel)
          @channel = channel
          send_data "JOIN ##{channel.name}"
        end

        def part_channel
          send_data "PART ##{channel.name}"
          @channel = nil
        end

        private

        attr_reader :socket, :client, :channel

        def open_socket
          connection = client.connection
          @socket = ::TCPSocket.new(
            connection.hostname,
            connection.port,
          )

          Twitch::Bot::Logger.debug "Socket open"
        end

        def close_socket
          socket.close
          Twitch::Bot::Logger.debug "Socket closed"
        end

        def read_data_from_socket
          Twitch::Bot::Logger.debug "Reading socket..."
          data = socket_read_next
          Twitch::Bot::Logger.debug "< #{data}"
          data
        end

        # Acceptable :reek:NilCheck
        def socket_read_next
          loop do
            line = socket.gets&.chomp
            break unless line.nil? || line.empty?
          end
          line
        end

        def send_data_to_socket(data)
          Twitch::Bot::Logger.debug "> #{sanitize_data(data)}"
          socket.puts(data)
        end

        def enable_twitch_capabilities
          send_data <<~DATA
            CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership
          DATA
        end

        def authenticate
          connection = client.connection
          send_data "PASS #{connection.password}"
          send_data "NICK #{connection.nickname}"
        end

        def sanitize_data(data)
          data.gsub(/(PASS oauth:)(\w+)/) do
            "#{Regexp.last_match(1)}#{'*' * Regexp.last_match(2).size}"
          end
        end
      end
    end
  end
end
