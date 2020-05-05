# frozen_string_literal: true

RSpec.describe Twitch::Bot::CommandHandler do
  it "responds to user_message" do
    expect(described_class.handled_events).to include(:user_message)
  end

  it "responds to a known command" do
    config = Twitch::Bot::Config.new
    client = Twitch::Bot::Client.new(config: config)
    message = Twitch::Bot::Message::UserMessage.new(
      text: "!mycommand test",
      user: "testuser",
    )
    handler = described_class.new(event: message, client: client)
    handler.command_alias("mycommand")
    allow(handler).to receive(:handle_command)

    handler.call

    expect(handler).to have_received(:handle_command)
  end
end
