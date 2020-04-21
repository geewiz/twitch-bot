# frozen_string_literal: true

module Twitch
  module Bot
    # This class stores the connection details for the client.
    class Config
      def initialize(settings: {})
        @settings = settings
      end

      def setting(name)
        conf = settings
        name_str = name.to_s
        name_str.split("_").each do |key|
          return nil if conf.nil?

          conf = conf.fetch(key.to_sym, nil)
        end
        conf
      end

      private

      attr_reader :settings
    end
  end
end
