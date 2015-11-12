module APNS
  require 'socket'
  require 'openssl'
  require 'json'

  @host = 'gateway.sandbox.push.apple.com'
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
    self.send_notifications([n])
  end

  def self.send_notifications(notifications)
    sock, ssl = self.open_connection

    packed_nofications = self.packed_nofications(notifications)

    ssl.write(packed_nofications)

    ssl.close
    sock.close
  end

  def self.packed_nofications(notifications)
    bytes = ''

    notifications.each do |notification|
      bytes << notification.packaged_notification
    end

    bytes
  end

  def self.feedback
    sock, ssl = self.feedback_connection

    apns_feedback = []

    while message = ssl.read(38)
      timestamp, token_size, token = message.unpack('N1n1H*')
      apns_feedback << [Time.at(timestamp), token]
    end

    ssl.close
    sock.close

    return apns_feedback
  end

  def self.pem_content
    if pem.is_a? Proc
      pem.call
    else
      @pem_content || read_pem
    end
  end

  protected

  def self.read_pem
    raise "The path to your pem file is not set. (APNS.pem = /path/to/cert.pem)" unless pem
    raise "The path to your pem file does not exist!" unless File.exist?(pem)

    File.read pem
  end

  def self.open_connection
    context      = OpenSSL::SSL::SSLContext.new
    context.cert = OpenSSL::X509::Certificate.new(pem_content)
    context.key  = OpenSSL::PKey::RSA.new(pem_content, self.pass)

    sock         = TCPSocket.new(self.host, self.port)
    ssl          = OpenSSL::SSL::SSLSocket.new(sock,context)
    ssl.connect

    return sock, ssl
  end

  def self.feedback_connection
    context      = OpenSSL::SSL::SSLContext.new
    context.cert = OpenSSL::X509::Certificate.new(pem_content)
    context.key  = OpenSSL::PKey::RSA.new(pem_content, self.pass)

    fhost = self.host.gsub('gateway','feedback')
    puts fhost

    sock         = TCPSocket.new(fhost, self.feedback_port)
    ssl          = OpenSSL::SSL::SSLSocket.new(sock,context)
    ssl.connect

    return sock, ssl
  end
end
