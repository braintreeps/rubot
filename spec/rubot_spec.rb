require 'spec_helper'

describe Rubot do
  before :all do
    @rubot_thread = Thread.new { Rubot.run }
  end

  describe 'rand' do
    it 'responds with a number between one and ten' do
      TestBot.deliver('rubot@braintreepayments.com', 'rand')
      sleep 3
      received_messages = TestBot.received_messages.map(&:body)
      received_messages.length.should == 1
      number = received_messages.first.to_i
      number.should >= 1
      number.should <= 11
    end
  end

  describe 'environments' do
    it 'responds with some environments' do
      env_response = [{
        :id => 1,
        :name => 'qa',
        :reserved_by => 'whoever',
        :updated_at => Time.now
      }]
      stub_request(:get, 'http://localhost:3000/environments.json').to_return(:body => env_response.to_json)
      TestBot.deliver('rubot@braintreepayments.com', 'environments')
      sleep 3
      received_messages = TestBot.received_messages.map(&:body)
      received_messages.length.should == 1
      received_messages.first.should include('qa was reserved by whoever')
    end
  end
end
