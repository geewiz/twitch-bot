# frozen_string_literal: true

module Twitch
  module Bot
    module Adapter
      # This adapter connects the chat client to the terminal
      class Terminal
        def initialize(client:)
          @client = client
        end

        def connect; end

        def shutdown; end

        def read_data
          read_message_from_terminal
        end

        def send_message(text)
          send_data(text)
        end

        def send_data(data)
          puts sanitize_data(data)
        end

        def join_channel(_channel); end

        def part_channel; end

        private

        attr_reader :client

        def sanitize_data(data)
          data.gsub(/(PASS oauth:)(\w+)/) do
            "#{Regexp.last_match(1)}#{'*' * Regexp.last_match(2).size}"
          end
        end

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
