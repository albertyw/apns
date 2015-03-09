require File.dirname(__FILE__) + '/../spec_helper'

describe APNS do

  describe "#pem_content" do
    before :each do
      APNS.pem_content = nil
      APNS.pem = nil
    end
    it "can read pem_content variable directly" do
      APNS.pem_content = 'asdf'
      APNS.pem_content.should eq 'asdf'
    end
    it "can read pem_content from a file" do
      APNS.pem = 'file'
      APNS.stub!(:read_pem).and_return('qwer')
      APNS.pem_content.should eq 'qwer'
    end
    it "can read pem_content from a Proc" do
      APNS.pem = lambda { return Random.rand }
      value1 = APNS.pem_content
      value2 = APNS.pem_content
      value1.should be_between(0, 1)
      value2.should be_between(0, 1)
      value1.should_not eq value2
    end
  end

end
