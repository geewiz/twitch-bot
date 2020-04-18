# frozen_string_literal: true

require "bundler/setup"
Bundler.require(:default)

require_relative "bot/version"
require_relative "bot/logger"
require_relative "bot/event"
require_relative "bot/event_handler"
require_relative "bot/default_handlers"
require_relative "bot/message"
require_relative "bot/irc_message"
require_relative "bot/message_parser"
require_relative "bot/channel"
require_relative "bot/connection"
require_relative "bot/adapter/irc"
require_relative "bot/adapter/terminal"
require_relative "bot/client"
