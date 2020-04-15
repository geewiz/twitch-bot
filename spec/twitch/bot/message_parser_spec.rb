# frozen_string_literal: true

RSpec.describe Twitch::Bot::MessageParser do
  context "when we receive a PRIVMSG message" do
    it "parses a chat message event" do
      irc_message = Twitch::Bot::IrcMessage.new(<<~RAW)
        :enotpoloskun!enotpoloskun@enotpoloskun.tmi.twitch.tv PRIVMSG #enotpoloskun :BibleThump
      RAW

      event = described_class.new(irc_message).message

      expect(event.type).to eq :user_message
      expect(event.text).to eq "BibleThump"
      expect(event.user).to eq "enotpoloskun"
    end

    it "parses a slow_mode enable event" do
      irc_message = Twitch::Bot::IrcMessage.new(<<~RAW)
        @room-id=117474239;slow=10 :tmi.twitch.tv ROOMSTATE #alexwayfer
      RAW

      event = described_class.new(irc_message).message

      expect(event.type).to eq :slow_mode
      expect(event.status).to eq "10"
      expect(event.channel).to eq "alexwayfer"
    end

    it "parses a slow mode disable event" do
      irc_message = Twitch::Bot::IrcMessage.new(<<~RAW)
        @room-id=117474239;slow=0 :tmi.twitch.tv ROOMSTATE #alexwayfer
      RAW

      event = described_class.new(irc_message).message

      expect(event.type).to eq :slow_mode
      expect(event.status).to eq "0"
      expect(event.channel).to eq "alexwayfer"
    end

    it "parses an r9k mode enable event" do
      irc_message = Twitch::Bot::IrcMessage.new(<<~RAW)
        @r9k=1;room-id=117474239 :tmi.twitch.tv ROOMSTATE #alexwayfer
      RAW

      event = described_class.new(irc_message).message

      expect(event.type).to eq :r9k_mode
      expect(event.status).to eq "1"
      expect(event.channel).to eq "alexwayfer"
    end

    it "parses an r9k mode disable event" do
      irc_message = Twitch::Bot::IrcMessage.new(<<~RAW)
        @r9k=0;room-id=117474239 :tmi.twitch.tv ROOMSTATE #alexwayfer
      RAW

      event = described_class.new(irc_message).message

      expect(event.type).to eq :r9k_mode
      expect(event.status).to eq "0"
      expect(event.channel).to eq "alexwayfer"
    end

    it "parses a subs-only mode enable event" do
      irc_message = Twitch::Bot::IrcMessage.new(<<~RAW)
        @room-id=128644134;subs-only=1 :tmi.twitch.tv ROOMSTATE #sad_satont
      RAW

      event = described_class.new(irc_message).message

      expect(event.type).to eq :subs_only_mode
      expect(event.channel).to eq "sad_satont"
    end

    it "parses a subs-only mode disable event" do
      irc_message = Twitch::Bot::IrcMessage.new(<<~RAW)
        @room-id=128644134;subs-only=0 :tmi.twitch.tv ROOMSTATE #sad_satont
      RAW

      event = described_class.new(irc_message).message

      expect(event.type).to eq :subs_only_mode
      expect(event.channel).to eq "sad_satont"
    end

    it "handles a subscription event" do
      irc_message = Twitch::Bot::IrcMessage.new(<<~RAW)
        :twitchnotify!twitchnotify@twitchnotify.tmi.twitch.tv PRIVMSG #enotpoloskun :enotpoloskun just subscribed!
      RAW

      event = described_class.new(irc_message).message

      expect(event.type).to eq :subscription
      expect(event.user).to eq "enotpoloskun"
    end
  end

  it "handles a MODE event" do
    irc_message = Twitch::Bot::IrcMessage.new(<<~RAW)
      :jtv MODE #enotpoloskun +o enotpoloskun
    RAW

    event = described_class.new(irc_message).message

    expect(event.user).to eq "enotpoloskun"
    expect(event.type).to eq :mode
  end

  it "parses a PING event" do
    host = "tmi.twitch.tv"
    irc_message = Twitch::Bot::IrcMessage.new(<<~RAW)
      PING :#{host}
    RAW

    event = described_class.new(irc_message).message

    expect(event.type).to eq :ping
    expect(event.hostname).to eq host
  end

  it "parses a NOTIFY event" do
    irc_message = Twitch::Bot::IrcMessage.new(<<~RAW)
      :tmi.twitch.tv NOTICE * :Login authentication failed
    RAW

    event = described_class.new(irc_message).message

    expect(event.user).to eq nil
    expect(event.type).to eq :login_failed
  end
end
