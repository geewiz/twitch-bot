# Changelog Twitch::Bot

## v2.0.0

* [BREAKING] The standard text message class is now named
`Twitch::Bot::Message::UserMessage` and uses the type symbol `:user_message`. It has added methods to handle bot commands.
* [CHANGED] Major restructuring of both class hierarchy and class responsibilities.

## v1.0.0 Initial release

This is the first release of `Twitch::Bot`, a fork and evolution of the `Twitch::Chat` gem. Its goal is to become a cleanly designed framework for building Twitch chat bots.
