# frozen_string_literal: true

RSpec.describe Twitch::Bot::Config do
  describe "#setting" do
    it "returns a first-level setting" do
      config = described_class.new(
        settings: {
          test: "Test",
          foo: "bar",
        },
      )

      expect(config.setting("test")).to eq "Test"
    end

    it "returns a second-level setting" do
      config = described_class.new(
        settings: {
          test: {
            foo: "bar",
          },
        },
      )

      expect(config.setting("test_foo")).to eq "bar"
    end
  end
end
