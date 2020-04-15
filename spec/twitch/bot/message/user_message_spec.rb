# frozen_string_literal: true

RSpec.describe Twitch::Bot::Message::UserMessage do
  it "recognizes a bot command" do
    message = described_class.new(
      text: "!command argument1",
      user: "tester",
    )

    expect(message.command?).to be true
  end

  it "recognizes a specific bot command" do
    message = described_class.new(
      text: "!command argument1",
      user: "tester",
    )

    expect(message.command_name?("command")).to be true
  end

  it "does not recognize normal text as a command" do
    message = described_class.new(
      text: "nocommand here",
      user: "tester",
    )

    binding.pry
    expect(message.command?).to be false
  end

  it "does not mistake text for a command" do
    message = described_class.new(
      text: "nocommand here",
      user: "tester",
    )

    expect(message.command_name?("nocommand")).to be false
  end

  it "parses a bot command" do
    message = described_class.new(
      text: "!command argument1",
      user: "tester",
    )

    expect(message.command).to eq "command"
  end

  it "does not return a command for normal text" do
    message = described_class.new(
      text: "nocommand here",
      user: "tester",
    )

    expect(message.command).to be nil
  end
end
