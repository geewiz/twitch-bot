# frozen_string_literal: true

module Twitch
  module Bot
    # Twitch chat client object
    class Client
      # Respond to a :ping event with a pong so we don't get disconnected.
      class PingHandler < Twitch::Bot::EventHandler
        def call
          client.send_data "PONG :#{event.hostname}"
        end

        def self.handled_events
          [:ping]
        end
      end

      # Handle the :authenticated event required for joining our channel.
      class AuthenticatedHandler < Twitch::Bot::EventHandler
        def call
          client.join_default_channel
        end

        def self.handled_events
          [:authenticated]
        end
      end

      # Handle a change in moderators on the channel.
      class ModeHandler < Twitch::Bot::EventHandler
        def call
          user = event.user
          case event.mode
          when :add_moderator
            client.add_moderator(user)
          when :remove_moderator
            client.remove_moderator(user)
          end
        end

        def self.handled_events
          [:mode]
        end
      end
    end
  end
end
