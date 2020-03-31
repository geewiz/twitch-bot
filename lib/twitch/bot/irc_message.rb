# frozen_string_literal: true

module Twitch
  module Bot
    # This class parses the tags portion in an IRC message.
    # rubocop:disable Layout/LineLength
    # <message>       ::= ['@' <tags> <SPACE>] [':' <prefix> <SPACE> ] <command> <params> <crlf>
    # <tags>          ::= <tag> [';' <tag>]*
    # <tag>           ::= <key> ['=' <escaped_value>]
    # <key>           ::= [ <client_prefix> ] [ <vendor> '/' ] <key_name>
    # <client_prefix> ::= '+'
    # <key_name>      ::= <non-empty sequence of ascii letters, digits, hyphens ('-')>
    # <escaped_value> ::= <sequence of zero or more utf8 characters except NUL, CR, LF, semicolon (`;`) and SPACE>
    # <vendor>        ::= <host>
    # rubocop:enable Layout/LineLength
    class IrcMessageTags
      attr_reader :tags

      def initialize(raw_tags)
        @raw_tags = raw_tags
        @tags = parse
      end

      def [](key)
        @tags[key]
      end

      def include?(key)
        @tags.key?(key)
      end

      def numeric_state(key, name, off_value:)
        return unless tags.key?(key)

        case tags[key]
        when off_value
          "#{name}_off".to_sym
        else
          name.to_sym
        end
      end

      def boolean_state(key, name)
        return unless tags.key?(key)

        case tags[key]
        when "1"
          name
        when "0"
          "#{name}_off".to_sym
        else
          raise "Unsupported value of '#{key}'"
        end
      end

      private

      attr_reader :raw_tags

      def parse
        return unless raw_tags

        raw_tags.
          split(";").
          map { |key_value| key_value.split("=", 2) }.
          to_h
      end
    end

    # This class parses the params portion of an IRC message.
    class IrcMessageParams
      attr_reader :params

      def initialize(raw_params)
        @raw_params = raw_params.strip
        @params = parse
      end

      private

      attr_reader :raw_params

      def parse
        if (match = raw_params.match(/(?:^:| :)(.*)$/))
          params = match.pre_match.split(" ")
          params << match[1]
        else
          raw_params.split(" ")
        end
      end
    end

    # This class splits an IRC message into its basic parts.
    # see https://ircv3.net/specs/extensions/message-tags.html#format
    #
    # rubocop:disable Layout/LineLength
    # <message>       ::= ['@' <tags> <SPACE>] [':' <prefix> <SPACE> ] <command> <params> <crlf>
    # rubocop:enable Layout/LineLength
    class IrcMessage
      attr_reader :tags, :prefix, :command, :params

      def initialize(msg)
        raw_tags, @prefix, @command, raw_params = msg.match(
          /^(?:@(\S+) )?(?::(\S+) )?(\S+)(.*)/,
        ).captures

        @tags = IrcMessageTags.new(raw_tags)
        @params = IrcMessageParams.new(raw_params).params
      end

      def error
        command[/[45]\d\d/] ? command.to_i : 0
      end

      def error?
        error.positive?
      end

      def target
        channel || user
      end

      def text
        if error?
          error.to_s
        else
          params.last
        end
      end

      def user
        return unless prefix

        prefix[/^(\S+)!/, 1]
      end

      # Not really a :reek:NilCheck
      def channel
        params.detect { |param| param.start_with?("#") }&.delete("#")
      end
    end
  end
end
