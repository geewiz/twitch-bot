# frozen_string_literal: true

RSpec.describe Twitch::Bot::Memory::Hash do
  describe "#store" do
    it "persists a value for a key" do
      mem = described_class.new(client: nil)

      mem.store("foo", "bar")

      expect(mem.retrieve("foo")).to eq "bar"
    end
  end
end
