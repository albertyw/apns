require File.dirname(__FILE__) + '/../spec_helper'

describe APNS do

  describe "#pem_content" do
    before :each do
      APNS.pem_content = nil
      APNS.pem = nil
    end
    it "can read pem_content variable directly" do
      APNS.pem_content = 'asdf'
      expect(APNS.pem_content).to eq 'asdf'
    end
    it "can read pem_content from a file" do
      APNS.pem = 'file'
      expect(APNS).to receive(:read_pem).and_return('qwer')
      expect(APNS.pem_content).to eq 'qwer'
    end
    it "can read pem_content from a Proc" do
      APNS.pem = lambda { return Random.rand }
      value1 = APNS.pem_content
      value2 = APNS.pem_content
      expect(value1).to be_between(0, 1)
      expect(value2).to be_between(0, 1)
      expect(value1).not_to eq value2
    end
  end

end
