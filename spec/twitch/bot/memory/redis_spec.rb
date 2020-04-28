# frozen_string_literal: true

RSpec.describe Twitch::Bot::Memory::Redis do
  describe "#store" do
    it "works with default connection details" do
      config = Twitch::Bot::Config.new(
        settings: {
          bot_user: "testuser",
        },
      )
      client = Twitch::Bot::Client.new(
        config: config,
        channel: "testchannel",
      )
      mem = described_class.new(client: client)

      mem.store("foo", "bar")

      expect(mem.retrieve("foo")).to eq "bar"
    end
  end

  it "works with ENV connection details" do
    ENV["REDIS_URL"] = "redis://localhost:6379"
    config = Twitch::Bot::Config.new(
      settings: {
        bot_user: "testuser",
      },
    )
    client = Twitch::Bot::Client.new(
      config: config,
      channel: "testchannel",
    )
    mem = described_class.new(client: client)

    mem.store("foo", "bar")

    expect(mem.retrieve("foo")).to eq "bar"
  end

  it "works with config connection details" do
    config = Twitch::Bot::Config.new(
      settings: {
        bot_user: "testuser",
        redis: {
          host: "localhost",
          port: 6379,
        },
      },
    )
    client = Twitch::Bot::Client.new(
      config: config,
      channel: "testchannel",
    )
    mem = described_class.new(client: client)

    mem.store("foo", "bar")

    expect(mem.retrieve("foo")).to eq "bar"
  end
end
