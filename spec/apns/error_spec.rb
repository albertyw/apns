require File.dirname(__FILE__) + "/../spec_helper"

describe APNS do
  describe 'Error' do
    it 'exists' do
      APNS::Error
    end
  end
  describe '.check_error' do
    it 'will not raise error if the code is 0' do
      expect{APNS.check_error 0}.to_not raise_error
    end
    it 'will raise the correct error' do
      expect{APNS.check_error 8}.to raise_error APNS::Error, 'Invalid token'
    end
    it 'will raise a default error if the code is unknown' do
      expect{APNS.check_error 20}.to raise_error APNS::Error
    end
  end
end
