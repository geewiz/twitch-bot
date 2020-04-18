# frozen_string_literal: true

module Twitch
  module Bot
    module Message
      # This class stores the details of a user's chat message.
      class UserMessage < Base
        attr_reader :text, :user

        def initialize(text:, user:)
          @text = text
          @user = user
          @type = :user_message
        end

        def command_name?(check_command)
          command == check_command
        end

        def command?
          !(command.nil? || command.empty?)
        end

        def command
          first_word&.match(/^!(\w+)/) do |match|
            match.captures&.first
          end
        end

        def command_args
          text_words.tap(&:shift)
        end

        private

        def text_words
          text.split(/\s+/)
        end

        def first_word
          text_words.first
        end
      end
    end
  end
end
