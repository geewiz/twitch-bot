# frozen_string_literal: true

RSpec.describe Twitch::Bot::Client do
  let!(:client) do
    connection = Twitch::Bot::Connection.new(
      nickname: "test", password: "test",
    )
    described_class.new(connection: connection)
  end

  describe "#trigger" do
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
end
