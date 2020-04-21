# frozen_string_literal: true

module Twitch
  module Bot
    module Adapter
      # This adapter connects the chat client to the terminal
      class Terminal
        def initialize(client:); end

        def connect; end

        def shutdown; end

        def read_data
          read_message_from_terminal
        end

        def send_message(text)
          send_data(text)
        end

        def send_data(data)
          puts data
        end

        def join_channel(_channel); end

        def part_channel; end

        private

        attr_reader :client

        def read_message_from_terminal
          Twitch::Bot::Logger.debug "Waiting for input..."
          input = gets
          Twitch::Bot::Message::UserMessage.new(
            text: input,
            user: "tester",
          )
        end
      end
    end
  end
end
