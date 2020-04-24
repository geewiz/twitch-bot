# frozen_string_literal: true

RSpec.describe Twitch::Bot::Memory::Redis do
  describe "#store" do
    it "persists a value for a key" do
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
end
