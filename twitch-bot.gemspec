# frozen_string_literal: true

require_relative "lib/twitch/bot/version"

Gem::Specification.new do |spec|
  spec.name          = "twitch-bot"
  spec.version       = Twitch::Bot::VERSION
  spec.authors       = ["Jochen Lillich"]
  spec.email         = ["contact@geewiz.dev"]
  spec.summary       = <<~SUMMARY
    twitch-bot is a Twitch chat client that uses Twitch IRC that can be used as a Twitch chat bot engine.
  SUMMARY
  spec.description = <<~DESC
    twitch-bot is a Twitch chat client that uses Twitch IRC.
    With the help of this library you can connect to any Twitch channel and handle chat events.
  DESC
  spec.homepage      = "https://github.com/geewiz/twitch-bot"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "redis", "~> 4.1"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "freistil-rubocop"
  spec.add_development_dependency "guard", "~> 2.16"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "pry-byebug", "~> 3.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "reek"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "solargraph"
  spec.add_development_dependency "terminal-notifier-guard"
end
