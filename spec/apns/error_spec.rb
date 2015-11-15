require File.dirname(__FILE__) + "/../spec_helper"

describe APNS do
  describe 'Error' do
    it 'exists' do
      APNS::Error
    end
  end
  describe '.check_error' do
    let(:notification) { APNS::Notification.new 'asdf', 'qwer' }
    it 'will not raise error if the code is 0' do
      expect{APNS.check_error 0, notification}.to_not raise_error
    end
    it 'will raise the correct error' do
      expect{APNS.check_error 8, notification}.to raise_error APNS::Error, 'Invalid token for asdf'
    end
    it 'will raise a default error if the code is unknown' do
      expect{APNS.check_error 20, notification}.to raise_error APNS::Error, 'Unknown error code for asdf'
    end
  end
end
