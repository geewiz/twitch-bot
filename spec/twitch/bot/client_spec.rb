# frozen_string_literal: true

RSpec.describe Twitch::Bot::Client do
  let!(:client) do
    config = Twitch::Bot::Config.new(
      settings: {
        bot_user: "testuser",
        adapter: "Twitch::Bot::Adapter::Terminal",
      },
    )
    described_class.new(
      config: config,
      channel: "testchannel",
    )
  end

  describe "#dispath" do
    it "responds to a Ping message" do
      ping_message_fake = Struct.new(:type, :hostname, :user)
      message = ping_message_fake.new(:ping, "test.twitch", nil)
      allow(client).to receive(:send_data)

      client.dispatch(message)

      expect(client).to have_received(:send_data)
    end

    it "responds to an Authenticate message" do
      fake_message_class = Struct.new(:type)
      message = fake_message_class.new(:authenticated)
      allow(client).to receive(:join_default_channel)

      client.dispatch(message)

      expect(client).to have_received(:join_default_channel)
    end

    it "responds to a +o message" do
      fake_message_class = Struct.new(:type, :user, :mode)
      message = fake_message_class.new(:mode, "Test", :add_moderator)
      allow(client).to receive(:add_moderator)

      client.dispatch(message)

      expect(client).to have_received(:add_moderator)
    end

    it "responds to a -o message" do
      fake_message_class = Struct.new(:type, :user, :mode)
      message = fake_message_class.new(:mode, "Test", :remove_moderator)
      allow(client).to receive(:remove_moderator)

      client.dispatch(message)

      expect(client).to have_received(:remove_moderator)
    end
  end

  describe "#channel" do
    it "returns the channel object" do
      channel = client.channel

      expect(channel.name).to eq "testchannel"
    end
  end

  describe "#memory" do
    it "stores and retrieves data" do
      client.memory.store("foo", "bar")

      expect(client.memory.retrieve("foo")).to eq "bar"
    end
  end
end
