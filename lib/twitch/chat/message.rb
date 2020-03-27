# frozen_string_literal: true

module Twitch
  module Chat
    class Message
      attr_reader(
        :type, :text, :user, :params, :command, :raw, :prefix, :error,
        :channel, :target
      )

      def initialize(msg)
        @raw = msg

        raw_additional_info, @prefix, @command, raw_params = msg.match(
          /^(?:@(\S+) )?(?::(\S+) )?(\S+)(.*)/
        ).captures
        @additional_info = parse_additional_info raw_additional_info
        @params = parse_params raw_params
        @user = parse_user
        @channel = parse_channel
        @target  = @channel || @user
        @error = parse_error
        @text = parse_text
        @type = parse_type
      end

      def error?
        !@error.nil?
      end

      private

      def parse_additional_info(raw_additional_info)
        return unless raw_additional_info

        raw_additional_info
          .split(';')
          .map { |key_value| key_value.split('=', 2) }
          .to_h
      end

      def parse_params(raw_params)
        raw_params = raw_params.strip

        params = []
        if (match = raw_params.match(/(?:^:| :)(.*)$/))
          params = match.pre_match.split(' ')
          params << match[1]
        else
          params = raw_params.split(' ')
        end

        params
      end

      def parse_user
        return unless @prefix

        nick = @prefix[/^(\S+)!/, 1]

        return nil if nick.nil?

        nick
      end

      def parse_channel
        @params.find { |param| param.start_with?('#') }&.delete('#')
      end

      def parse_error
        @command.to_i if numeric_reply? && @command[/[45]\d\d/]
      end

      def parse_text
        if error?
          @error.to_s
        elsif regular_command?
          @params.last
        end
      end

      def numeric_reply?
        !@command.match(/^\d{3}$/).nil?
      end

      def regular_command?
        !numeric_reply?
      end

      def parse_type
        case @command
        when 'PRIVMSG' then parse_message_type
        when 'MODE' then :mode
        when 'PING' then :ping
        when 'ROOMSTATE' then parse_roomstate_type
        when 'NOTICE' then parse_notice_type
        # You are in a maze
        when '372' then :authenticated
        # 'End of /NAMES list'
        when '366' then :join
        else :not_supported
        end
      end

      def parse_message_type
        case @user
        when 'twitchnotify'
          case text
          when /just subscribed!/ then :subscribe
          else :not_supported
          end
        else :message
        end
      end

      def parse_roomstate_type
        parse_roomstate_integer_type('slow', :slow_mode, off_value: '0') ||
          parse_roomstate_integer_type(
            'followers-only', :followers_mode, off_value: '-1'
          ) ||
          parse_roomstate_boolean_type('subs-only', :subscribers_mode) ||
          parse_roomstate_boolean_type('r9k', :r9k_mode) ||
          :not_supported
      end

      def parse_roomstate_boolean_type(key, name)
        value = @additional_info[key]
        return unless value

        case value
        when '1' then name
        when '0' then :"#{name}_off"
        else raise "Unsupported value of `#{key}`"
        end
      end

      def parse_roomstate_integer_type(key, name, off_value:)
        value = @additional_info[key]
        return unless value

        if value == off_value then :"#{name}_off"
        else name
        end
      end

      def parse_notice_type
        case @params.last
        when /Login authentication failed/ then :login_failed
        else :not_supported
        end
      end
    end
  end
end
