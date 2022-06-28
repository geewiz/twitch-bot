# frozen_string_literal: true

require "logger"

Thread.abort_on_exception = true

module Twitch
  module Bot
    # Twitch chat client object
    class Client
      # Represent the event triggered when quitting the client loop.
      class StopEvent < Twitch::Bot::Event
        def initialize
          super(type: :stop)
        end
      end

      MODERATOR_MESSAGES_COUNT = 100
      USER_MESSAGES_COUNT = 20
      TWITCH_PERIOD = 30.0

      attr_reader :channel, :config, :memory

      def initialize(
        config:, channel: nil, &block
      )
        @config = config
        @channel = Twitch::Bot::Channel.new(channel) if channel

        @messages_queue = []
        @event_handlers = {}
        @event_loop_running = false

        setup_logging

        memory_class = config.setting("memory") || "Twitch::Bot::Memory::Hash"
        @memory = Object.const_get(memory_class).new(client: self)

        adapter_class = config.setting("adapter") || "Twitch::Bot::Adapter::Irc"
        @adapter = Object.const_get(adapter_class).new(client: self)

        execute_initialize_block block if block
        register_default_handlers
      end

      #
      # Register an event handler for specific event types
      #
      # @param [<EventHandler>] handler EventHandler class to register
      #
      def register_handler(handler)
        handler.handled_events.each do |event_type|
          (event_handlers[event_type] ||= []) << handler
          Twitch::Bot::Logger.debug "Registered #{handler} for #{event_type}"
        end
      end

      def run
        startup

        # Wait for threads to finish
        input_thread.join
        output_thread.join
      end

      def join_default_channel
        adapter.join_channel(@channel) if @channel
      end

      def part_channel
        adapter.part_channel
        @channel = nil
        @messages_queue = []
      end

      def dispatch(event)
        type = event.type
        Twitch::Bot::Logger.debug "Dispatching #{type}..."
        (event_handlers[type] || []).each do |handler_class|
          Twitch::Bot::Logger.debug "Calling #{handler_class}..."
          handler_class.new(event: event, client: self).call
        end
      end

      def send_data(data)
        adapter.send_data(data)
      end

      def send_message(message)
        messages_queue << message if messages_queue.last != message
      end

      def add_moderator(user)
        channel.add_moderator(user)
      end

      def remove_moderator(user)
        channel.remove_moderator(user)
      end

      def stop
        dispatch StopEvent.new
        stop_event_loop
        part_channel if channel
      end

      private

      attr_reader :adapter, :event_handlers, :event_loop_running,
                  :input_thread, :output_thread, :messages_queue

      def setup_logging
        Twitch::Bot::Logger.output =
          config.setting(:log_file) || "twitchbot.log"
        Twitch::Bot::Logger.level =
          (config.setting(:log_level) || "info").to_sym
      end

      def startup
        set_traps
        start_event_loop
        start_input_thread
        start_output_thread
        adapter.connect
        Twitch::Bot::Logger.debug "Started."
      end

      def set_traps
        %w[TERM INT].each { |signal| trap(signal) { stop } }
      end

      def start_event_loop
        raise "Already running" if event_loop_running?

        @event_loop_running = true
      end

      def stop_event_loop
        @event_loop_running = false
      end

      def event_loop_running?
        @event_loop_running
      end

      def start_input_thread
        Twitch::Bot::Logger.debug("Starting input thread...")
        @input_thread = Thread.start do
          while event_loop_running?
            event = adapter.read_data
            dispatch(event)
          end
        end
      end

      def start_output_thread
        Twitch::Bot::Logger.debug("Starting output thread...")
        @output_thread = Thread.start do
          while event_loop_running?
            sleep message_delay

            if (message = messages_queue.pop)
              adapter.send_message(message)
            end
          end
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

      def max_messages_count
        if channel&.moderators.include?(config.setting("botname"))
          MODERATOR_MESSAGES_COUNT
        else
          USER_MESSAGES_COUNT
        end
      end

      def message_delay
        TWITCH_PERIOD / max_messages_count
      end
    end
  end
end
