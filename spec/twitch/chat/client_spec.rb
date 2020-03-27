# frozen_string_literal: true

describe Twitch::Chat::Client do
  let(:client) do
    Twitch::Chat::Client.new(password: 'password', nickname: 'enotpoloskun')
  end

  describe '#on' do
    context 'There is one message callback' do
      subject { client.instance_variable_get(:@callbacks)[:message].count }

      before { client.on(:message) { 'callback1' } }

      it { is_expected.to eq 1 }

      context 'There is another message callback' do
        before { client.on(:message) { 'callback2' } }

        it { is_expected.to eq 2 }
      end
    end
  end

  describe '#trigger' do
    before { client.on(:message) { client.inspect } }

    it { expect(client).to receive(:inspect) }

    after { client.trigger(:message) }
  end
end
