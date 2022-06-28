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
      url = URI.parse(ENV["REDIS_URL"])
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
    end

    it "persists an Array" do
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

      mem.store("foo", [1, 2])

      result = mem.retrieve("foo")
      expect(result).to be_an Array
      expect(result[0]).to eq 1
      expect(result[1]).to eq 2
    end

    it "persists a Hash" do
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

      mem.store("foo", { "bar" => "baz" })

      result = mem.retrieve("foo")
      expect(result).to be_a Hash
      expect(result["bar"]).to eq "baz"
    end
  end
end
