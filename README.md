# Twitch::Bot

`twitch-bot` provides a Twitch chat client object that can be used for building Twitch chat bots.

This gem is based on [`twitch-chat`](https://github.com/EnotPoloskun/twitch-chat).

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

Refer to the [Teneggs](https://www.github.com/geewiz/teneggs) repository for an example bot implementation.

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
