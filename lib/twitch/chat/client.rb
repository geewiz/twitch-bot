# frozen_string_literal: true

require 'logger'

Thread.abort_on_exception = true

module Twitch
  module Chat
    class Client
      MODERATOR_MESSAGES_COUNT = 100
      USER_MESSAGES_COUNT = 20
      TWITCH_PERIOD = 30.0

      def initialize(
        nickname:, password:,
        host: 'irc.chat.twitch.tv', port: '6667', output: STDOUT,
        channel: nil,
        &block
      )
        @logger = Logger.new(output) if output

        @host = host
        @port = port
        @nickname = nickname
        @password = password
        @channel = Twitch::Chat::Channel.new(channel) if channel

        @messages_queue = []

        @running = false
        @callbacks = {}

        execute_initialize_block block if block

        define_default_callbacks!
      end

      def on(callback, &block)
        (@callbacks[callback.to_sym] ||= []) << block
      end

      def trigger(event_name, *args)
        (@callbacks[event_name.to_sym] || []).each { |block| block.call(*args) }
      end

      def run!
        raise 'Already running' if @running

        @running = true

        %w[TERM INT].each { |signal| trap(signal) { stop } }

        connect

        @input_thread.join
        @messages_thread.join

        @logger.debug 'Joined'
      end

      def join(channel)
        @channel = Channel.new(channel)
        send_data "JOIN ##{@channel.name}"
      end

      def part
        send_data "PART ##{@channel.name}"
        @channel = nil
        @messages_queue = []
      end

      def send_message(message)
        @messages_queue << message if @messages_queue.last != message
      end

      def max_messages_count
        if @channel.moderators.include?(@nickname)
          MODERATOR_MESSAGES_COUNT
        else
          USER_MESSAGES_COUNT
        end
      end

      def message_delay
        TWITCH_PERIOD / max_messages_count
      end

      def stop
        trigger :stop
        @logger.debug '@running = false'
        @running = false
        part if @channel
      end

      def handle_input_data
        @input_thread = Thread.start do
          while @running
            line = @socket.gets&.chomp

            next unless line

            @logger.info "> #{line}"

            Twitch::Chat::Message.new(line).tap do |message|
              trigger(:raw, message)

              case message.type
              when :authenticated
                join @channel.name if @channel
                trigger :authenticated
              when :join
                trigger :join, message.channel
              when :ping
                trigger :ping, message.params.last
              when :message
                trigger :message, message
              when :mode
                trigger :mode, *message.params.last(2)

                if message.params[1] == '+o'
                  trigger :new_moderator, message.params.last
                elsif message.params[1] == '-o'
                  trigger :remove_moderator, message.params.last
                end
              when :slow_mode, :r9k_mode, :subscribers_mode, :slow_mode_off,
                   :r9k_mode_off, :subscribers_mode_off
                trigger message.type
              when :subscribe
                trigger :subscribe, message.params.last.split(' ').first
              when :not_supported
                trigger :not_supported, *message.params
              end
            end
          end
          @logger.debug 'End of input thread'
          @socket.close
        end
      end

      private

      def connect
        @socket = TCPSocket.new(@host, @port)

        handle_input_data

        handle_messages_queue

        send_data <<~DATA
          CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership
        DATA

        authenticate
      end

      def handle_messages_queue
        @messages_thread = Thread.start do
          while @running
            sleep message_delay

            if (message = @messages_queue.pop)
              send_data "PRIVMSG ##{@channel.name} :#{message}"
            end
          end

          @logger.debug 'End of messages thread'
        end
      end

      def send_data(data)
        log_data = data.gsub(/(PASS oauth:)(\w+)/) do
          "#{Regexp.last_match(1)}#{'*' * Regexp.last_match(2).size}"
        end
        @logger.info "< #{log_data}"

        @socket.puts(data)
      end

      def execute_initialize_block(block)
        if block.arity == 1
          block.call self
        else
          instance_eval(&block)
        end
      end

      def define_default_callbacks!
        on :new_moderator do |user|
          @channel.add_moderator(user)
        end

        on :remove_moderator do |user|
          @channel.remove_moderator(user)
        end

        on :ping do |host|
          send_data "PONG :#{host}"
        end
      end

      def authenticate
        send_data "PASS #{@password}"
        send_data "NICK #{@nickname}"
      end
    end
  end
end
