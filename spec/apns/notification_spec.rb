require File.dirname(__FILE__) + "/../spec_helper"

describe APNS::Notification do
  it "should take a string as the message" do
    n = APNS::Notification.new("device_token", "Hello")
    expect(n.alert).to eq("Hello")
  end

  it "should take a hash as the message" do
    n = APNS::Notification.new("device_token", { alert: "Hello iPhone", badge: 3 })
    expect(n.alert).to eq("Hello iPhone")
    expect(n.badge).to eq(3)
  end

  it "should have a priority if content_availible is set" do
    n = APNS::Notification.new("device_token", { content_available: true })
    expect(n.content_available).to be_truthy
    expect(n.priority).to eql(5)
  end

  describe '#packaged_message' do
    it "should return JSON with notification information" do
      n = APNS::Notification.new("device_token", { alert: "Hello iPhone", badge: 3, sound: "awesome.caf" })
      expect(n.packaged_message).to eq("{\"aps\":{\"alert\":\"Hello iPhone\",\"badge\":3,\"sound\":\"awesome.caf\"}}")
    end

    it "should not include keys that are empty in the JSON" do
      n = APNS::Notification.new("device_token", { badge: 3 })
      expect(n.packaged_message).to eq("{\"aps\":{\"badge\":3}}")
    end

    it "should return JSON with content availible" do
      n = APNS::Notification.new("device_token", { content_available: true })
      expect(n.packaged_message).to eq("{\"aps\":{\"content-available\":1}}")
    end
  end

  describe '#package_token' do
    it "should package the token" do
      n = APNS::Notification.new("<5b51030d d5bad758 fbad5004 bad35c31 e4e0f550 f77f20d4 f737bf8d 3d5524c6>", "a")
      expect(Base64.encode64(n.packaged_token)).to eq("W1EDDdW611j7rVAEutNcMeTg9VD3fyDU9ze/jT1VJMY=\n")
    end
  end

  describe '#packaged_notification' do
    it "should package the token" do
      n = APNS::Notification.new("device_token", { alert: "Hello iPhone", badge: 3, sound: "awesome.caf" })
      expect(n).to receive(:message_identifier).and_return("aaaa") # make sure the message_identifier is not random
      expect(Base64.encode64(n.packaged_notification)).to eq("AgAAAF4BAAbe8s79hOcCAEB7ImFwcyI6eyJhbGVydCI6IkhlbGxvIGlQaG9u\nZSIsImJhZGdlIjozLCJzb3VuZCI6ImF3ZXNvbWUuY2FmIn19AwAEYWFhYQQA\nBAAAAAAFAAEK\n")
    end
  end
end
