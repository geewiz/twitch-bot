# frozen_string_literal: true

require "logger"
require "socket"

Thread.abort_on_exception = true

module Twitch
  module Bot
    # Twitch chat client object
    class Client
      MODERATOR_MESSAGES_COUNT = 100
      USER_MESSAGES_COUNT = 20
      TWITCH_PERIOD = 30.0

      # Respond to a :ping event with a pong so we don't get disconnected.
      class PingHandler < Twitch::Bot::EventHandler
        def call
          client.send_data "PONG :#{event.hostname}"
        end

        def self.handled_events
          [:ping]
        end
      end

      # Handle the :authenticated event required for joining our channel.
      class AuthenticatedHandler < Twitch::Bot::EventHandler
        def call
          client.join_default_channel
        end

        def self.handled_events
          [:authenticated]
        end
      end

      # Handle a change in moderators on the channel.
      class ModeHandler < Twitch::Bot::EventHandler
        def call
          user = event.user
          case event.mode
          when :add_moderator
            client.add_moderator(user)
          when :remove_moderator
            client.remove_moderator(user)
          end
        end

        def self.handled_events
          [:mode]
        end
      end

      # Represent the event triggered when quitting the client loop.
      class StopEvent < Twitch::Bot::Event
        def initialize
          @type = :stop
        end
      end

      attr_reader :connection

      def initialize(
        connection:, output: STDOUT, channel: nil, &block
      )
        @connection = connection
        @logger = Logger.new(output)
        @channel = Twitch::Bot::Channel.new(channel) if channel
        @messages_queue = []
        @running = false
        @event_handlers = {}

        execute_initialize_block block if block
        register_default_handlers
      end

      def dispatch(event)
        type = event.type
        logger.debug "Dispatched #{type}"
        (event_handlers[type] || []).each do |handler_class|
          logger.debug "Calling #{handler_class}..."
          handler_class.new(event: event, client: self).call
        end
      end

      def register_handler(handler)
        handler.handled_events.each do |event_type|
          (event_handlers[event_type] ||= []) << handler
          logger.debug "Registered #{handler} for #{event_type}"
        end
      end

      def run
        raise "Already running" if running

        @running = true

        %w[TERM INT].each { |signal| trap(signal) { stop } }

        connect
        input_thread.join
        messages_thread.join
        logger.info "Client ended."
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
        if @channel.moderators.include?(connection.nickname)
          MODERATOR_MESSAGES_COUNT
        else
          USER_MESSAGES_COUNT
        end
      end

      def message_delay
        TWITCH_PERIOD / max_messages_count
      end

      def stop
        dispatch StopEvent.new
        @running = false
        part if @channel
      end

      def send_data(data)
        log_data = data.gsub(/(PASS oauth:)(\w+)/) do
          "#{Regexp.last_match(1)}#{'*' * Regexp.last_match(2).size}"
        end
        logger.debug "< #{log_data}"

        if development_mode?
          send_data_to_terminal(data)
        else
          send_data_to_socket(data)
        end
      end

      def send_data_to_socket(data)
        socket.puts("PRIVMSG ##{@channel.name} :#{data}")
      end

      def send_data_to_terminal(data)
        puts "> #{data}"
      end

      def join_default_channel
        join @channel.name if @channel
      end

      def add_moderator(user)
        channel.add_moderator(user)
      end

      def remove_moderator(user)
        channel.remove_moderator(user)
      end

      private

      attr_reader :event_handlers, :running, :input_thread, :messages_thread,
                  :socket, :logger

      def connect
        @socket = ::TCPSocket.new(connection.hostname, connection.port)

        start_input_thread
        start_messages_thread
        enable_twitch_capabilities
        authenticate
      end

      def enable_twitch_capabilities
        send_data <<~DATA
          CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership
        DATA
      end

      def authenticate
        send_data "PASS #{connection.password}"
        send_data "NICK #{connection.nickname}"
      end

      def start_input_thread
        @input_thread = Thread.start do
          while running
            event = if development_mode?
                      read_message_from_terminal
                    else
                      read_message_from_socket
                    end
            dispatch(event)
          end

          logger.debug "End of input thread"
          socket.close
        end
      end

      def read_message_from_socket
        irc_message = IrcMessage.new(read_socket)
        Twitch::Bot::MessageParser.new(irc_message).message
      end

      def read_message_from_terminal
        puts "Your command?"
        input = gets
        Twitch::Bot::Message::UserMessage.new(
          text: input,
          user: "tester",
        )
      end

      def development_mode?
        ENV["BOT_MODE"] == "development"
      end

      # Acceptable :reek:NilCheck
      def read_socket
        line = ""
        while line.empty?
          line = socket.gets&.chomp
        end
        logger.debug "> #{line}"
        line
      end

      def start_messages_thread
        @messages_thread = Thread.start do
          while running
            sleep message_delay

            if (message = @messages_queue.pop)
              send_data message
            end
          end

          logger.debug "End of messages thread"
        end
      end

      def execute_initialize_block(block)
        if block.arity == 1
          block.call self
        else
          instance_eval(&block)
        end
      end

      def register_default_handlers
        register_handler(Twitch::Bot::Client::PingHandler)
        register_handler(Twitch::Bot::Client::AuthenticatedHandler)
        register_handler(Twitch::Bot::Client::ModeHandler)
      end
    end
  end
end
