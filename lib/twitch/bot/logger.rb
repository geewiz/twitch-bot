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
        # FIXME: Logger doesn't seem to be working properly
        puts entry
        logger.debug entry
      end

      def self.logger
        @logger ||= ::Logger.new($stdout)
      end
    end
  end
end
