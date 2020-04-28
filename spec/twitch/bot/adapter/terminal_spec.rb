# frozen_string_literal: true

RSpec.describe Twitch::Bot::Adapter::Terminal do
  describe "#receive_message" do
    it "receives all messages from channel owner" do
      config = Twitch::Bot::Config.new(
        settings: {
          bot_user: "testuser",
          adapter: "Twitch::Bot::Adapter::Terminal",
        },
      )
      client = Twitch::Bot::Client.new(
        config: config,
        channel: "testchannel",
      )
      adapter = described_class.new(client: client)
      allow(adapter).to receive(:read_terminal).and_return("Hello")

      message = adapter.read_data

      expect(message.user).to eq client.channel.name
    end
  end
end
