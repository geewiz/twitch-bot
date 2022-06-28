# frozen_string_literal: true

require "socket"

module Twitch
  module Bot
    module Adapter
      # Handle the bot's IRC connection
      class Irc
        def initialize(client:)
          @client = client
          @channel = nil

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
          privmsg = "PRIVMSG ##{@channel.name} :#{text}"
          send_data(privmsg)
        end

        def send_data(data)
          send_data_to_socket(data)
        end

        def join_channel(channel_object)
          @channel = channel_object
          send_data "JOIN ##{@channel.name}"
        end

        def part_channel
          send_data "PART ##{@channel.name}" if @channel
          @channel = nil
        end

        private

        attr_reader :socket, :client

        def open_socket
          @socket = ::TCPSocket.new(
            client.config.setting("irc_hostname") || "irc.chat.twitch.tv",
            client.config.setting("irc_port") || 6667,
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
          line = ""
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
          config = client.config
          send_data "PASS #{config.setting('irc_password')}"
          send_data "NICK #{config.setting('irc_nickname')}"
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
