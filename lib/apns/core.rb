module APNS
  require "socket"
  require "openssl"
  require "json"

  TIMEOUT = 0.2

  @host = "gateway.sandbox.push.apple.com"
  @port = 2195
  @feedback_port = 2196
  # openssl pkcs12 -in mycert.p12 -out client-cert.pem -nodes -clcerts
  @pem = nil # this should be the path of the pem file not the contents
  @pem_contents = nil # Contents of pem file
  @pass = nil

  class << self
    attr_accessor :host, :pem, :pem_content, :port, :feedback_port, :pass
  end

  def self.send_notification(device_token, message)
    n = APNS::Notification.new(device_token, message)
    send_notifications([n])
  end

  def self.send_notifications(notifications)
    sock, ssl = open_connection

    # prepares the messages to be sent
    notifications.each_with_index do |apns_notf, idx|
      apns_notf.message_identifier = [idx].pack('N')
    end

    # packs all notifications into a single pack
    packed_notifications = self.pack_notifications(notifications)

    # Send the notifications
    ssl.write(packed_notifications)

    result = nil
    begin
      result = process_notification_response ssl, notifications
    ensure
      ssl.close
      sock.close
    end
    result
  end

  def self.pack_notifications(notifications)
    bytes = ""

    notifications.each do |notification|
      bytes << notification.packaged_notification
    end

    bytes
  end

  def self.feedback
    sock, ssl = feedback_connection

    apns_feedback = []

    while message = ssl.read(38)
      timestamp, token_size, token = message.unpack("N1n1H*")
      apns_feedback << [Time.at(timestamp), token]
    end

    ssl.close
    sock.close

    apns_feedback
  end

  def self.pem_content
    if pem.is_a? Proc
      pem.call
    else
      @pem_content || read_pem
    end
  end

  protected

  def self.process_notification_response ssl, notifications
    if IO.select([ssl], nil, nil, TIMEOUT)
      if buffer = ssl.read(6)
        _, error_code, idx = buffer.unpack('CCN')
        error = error_code.to_i
        error_notification = notifications[idx.to_i]
        APNS.check_error error, error_notification
        return [error_code, idx]
      end
    end
  end

  def self.read_pem
    fail "The path to your pem file is not set. (APNS.pem = /path/to/cert.pem)" unless pem
    fail "The path to your pem file does not exist!" unless File.exist?(pem)

    File.read pem
  end

  def self.open_connection
    context      = OpenSSL::SSL::SSLContext.new
    context.cert = OpenSSL::X509::Certificate.new(pem_content)
    context.key  = OpenSSL::PKey::RSA.new(pem_content, pass)

    sock         = TCPSocket.new(host, port)
    ssl          = OpenSSL::SSL::SSLSocket.new(sock, context)
    ssl.connect

    [sock, ssl]
  end

  def self.feedback_connection
    context      = OpenSSL::SSL::SSLContext.new
    context.cert = OpenSSL::X509::Certificate.new(pem_content)
    context.key  = OpenSSL::PKey::RSA.new(pem_content, pass)

    fhost = host.gsub("gateway", "feedback")

    sock         = TCPSocket.new(fhost, feedback_port)
    ssl          = OpenSSL::SSL::SSLSocket.new(sock, context)
    ssl.connect

    [sock, ssl]
  end
end
