# frozen_string_literal: true

RSpec.describe Twitch::Bot::Memory::Redis do
  describe "#store" do
    it "works with ENV connection details" do
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
      # Override environment variable
      url = URI.parse(ENV["REDIS_URL"])
      ENV["REDIS_URL"] = nil

      config = Twitch::Bot::Config.new(
        settings: {
          bot_user: "testuser",
          redis: {
            host: url.host,
            port: url.port,
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
      ENV["REDIS_URL"] = url.to_s
    end
  end
end
