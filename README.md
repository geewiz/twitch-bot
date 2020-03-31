# Twitch::Bot

`twitch-bot` provides a Twitch chat client object that can be used for building Twitch chat bots.

This gem is based on the `twitch-chat` gem by https://github.com/EnotPoloskun.

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'twitch-bot'
```

Install all the dependencies:

```
$ bundle
```

Or install it manually via:

```
$ gem install twitch-bot
```

## Usage

```ruby
require "twitch/bot"

class JoinHandler < Twitch::Bot::EventHandler
  def call
    client.send_message "Hi guys!"
  end

  def self.handled_events
    [:join]
  end
end

class SubscriptionHandler < Twitch::Bot::EventHandler
  def call
    client.send_message "Hi #{event.user}, thank you for your subscription"
  end

  def self.handled_events
    [:subscription]
  end
end

class TimeCommandHandler < Twitch::Bot::EventHandler
  def call
    if event.bot_command?("time")
      client.send_message "Current time: #{Time.now.utc}"
    end
  end

  def self.handled_events
    [:chat_message]
  end
end

connection = Twitch::Bot::Connection.new(
  nickname: "test",
  password: "secret",
)

client = Twitch::Bot::Client.new(
  connection: connection,
  channel: "test",
) do
  register_handler(JoinHandler)
  register_handler(SubscriptionHandler)
  register_handler(TimeCommandHandler)
end

client.run
```

## Supported event types

* ``:authenticated``
* ``:join``
* ``:message``
* ``:slow_mode``
* ``:r9k_mode``
* ``:followers_mode``
* ``:subscribers_mode``
* ``:subscribe``
* ``:stop``
* ``:not_supported``

## Contributing

1. Fork the repo (https://github.com/geewiz/twitch-bot/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -a`)
4. Push the branch (`git push origin my-new-feature`)
5. Submit a Pull Request from your Github repository

Please take note of the Code Of Conduct in `CODE_OF_CONDUCT.md`.
