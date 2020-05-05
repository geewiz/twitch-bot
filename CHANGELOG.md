# Changelog Twitch::Bot

## v4.0.1

* [FIXED] Fixed test crash due to incomplete DotEnv initialization.

## v4.0.0

* [BREAKING] Using `REDIS_HOST` and `REDIS_PORT` for the connection details in `Twitch::Bot::Memory::Redis` was a bad choice. Providers like Heroku use a combined `REDIS_URL` instead. So do we now. (Alternatively, there's still the way via the `Config` object.)

## v3.2.1

* [FIXED] The Terminal adapter now returns all messages from the channel owner, allowing to test privileged functionality in dev mode.

## v3.2.0

* [NEW] This release introduces a `Memory::Redis` class that allows users to provide their bot with a persistent memory storage.

## v3.1.0

* [NEW] Client provides a persistent memory in form of a key/value store.

## v3.0.0

* [BREAKING] Instead of choosing and creating the `Adapter` in the `Client`, we now inject a `Config` class into `Client` that carries our choice of Adapter. This change also makes the `Connection` class obsolete; its information went into `Config` as well.

## v2.1.1

* [FIXED] Fix a few bugs missed by not running tests. We need CI...

## v2.1.0

* [NEW] Local development mode
* [CHANGED] Substantial refactoring introducing protocol Adapter classes and a central Logger class

## v2.0.0

* [BREAKING] The standard text message class is now named
`Twitch::Bot::Message::UserMessage` and uses the type symbol `:user_message`. It has added methods to handle bot commands.
* [CHANGED] Major restructuring of both class hierarchy and class responsibilities.

## v1.0.0 Initial release

This is the first release of `Twitch::Bot`, a fork and evolution of the `Twitch::Chat` gem. Its goal is to become a cleanly designed framework for building Twitch chat bots.
