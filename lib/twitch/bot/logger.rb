# frozen_string_literal: true

module Twitch
  module Bot
    class Logger
      def self.output=(file)
        @logger = ::Logger.new(file)
      end

      def self.level=(level)
        @logger.level = level
      end

      def self.debug(entry)
        logger.debug entry
      end

      def self.logger
        @logger ||= ::Logger.new(STDOUT)
      end
    end
  end
end
