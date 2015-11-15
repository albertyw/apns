require File.dirname(__FILE__) + "/../spec_helper"

describe APNS do
  describe '.send_notifications' do
    let(:notifications) { [APNS::Notification.new('token', 'message')] }
    let(:sock) { double(:sock) }
    let(:ssl) { double(:ssl) }

    before do
      expect(APNS).to receive(:open_connection).and_return([sock, ssl])
      expect(ssl).to receive(:write)
      expect(ssl).to receive(:close)
      expect(sock).to receive(:close)
    end

    it 'sets message_identifier' do
      expect(APNS).to receive(:process_notification_response)
      APNS.send_notifications notifications
      expect(notifications[0].message_identifier).to be
    end
    it 'will still close socket if it raises error' do
      expect(APNS).to receive(:process_notification_response).and_raise APNS::Error
      expect{APNS.send_notifications notifications}.to raise_error APNS::Error
    end
  end

  describe '.process_notification_response' do
    let(:notifications) { [APNS::Notification.new('token', 'message')] }
    let(:ssl) { double(:ssl) }

    it 'will read the error and send to .check_error' do
      expect(IO).to receive(:select).and_return true
      buffer = double(:buffer)
      expect(buffer).to receive(:unpack).and_return(['x', '5', '0'])
      expect(ssl).to receive(:read).and_return buffer
      expect(APNS).to receive(:check_error).with(5, notifications[0])
      APNS.process_notification_response ssl, notifications
    end
    it 'will skip if there is no response' do
      expect(IO).to receive(:select).and_return false
      expect(APNS).to_not receive(:check_error)
      APNS.process_notification_response ssl, notifications
    end
  end

  describe '#pem_content' do
    before :each do
      APNS.pem_content = nil
      APNS.pem = nil
    end
    it "can read pem_content variable directly" do
      APNS.pem_content = "asdf"
      expect(APNS.pem_content).to eq "asdf"
    end
    it "can read pem_content from a file" do
      APNS.pem = "file"
      expect(APNS).to receive(:read_pem).and_return("qwer")
      expect(APNS.pem_content).to eq "qwer"
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
