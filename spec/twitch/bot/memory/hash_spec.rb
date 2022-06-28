# frozen_string_literal: true

RSpec.describe Twitch::Bot::Memory::Hash do
  describe "#store" do
    it "persists a value for a key" do
      mem = described_class.new(client: nil)

      mem.store("foo", "bar")

      expect(mem.retrieve("foo")).to eq "bar"
    end

    it "persists an Array" do
      mem = described_class.new(client: nil)

      mem.store("foo", [1, 2])

      result = mem.retrieve("foo")
      expect(result).to be_an Array
      expect(result[0]).to eq 1
      expect(result[1]).to eq 2
    end

    it "persists a Hash" do
      mem = described_class.new(client: nil)

      mem.store("foo", { "bar" => "baz" })

      result = mem.retrieve("foo")
      expect(result).to be_a Hash
      expect(result["bar"]).to eq "baz"
    end
  end
end
