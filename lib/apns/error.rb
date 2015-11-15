module APNS
  ERROR_CODES = {
    0   => 'No errors encountered',
    1   => 'Processing error',
    2   => 'Missing device token',
    3   => 'Missing topic',
    4   => 'Missing payload',
    5   => 'Invalid token size',
    6   => 'Invalid topic size',
    7   => 'Invalid payload size',
    8   => 'Invalid token',
    10  => 'Shutdown',
    255 => 'None (unknown)',
  }

  class Error < RuntimeError
  end

  def self.check_error error_code
    error_code = error_code.to_i
    if error_code == 0
      return
    else
      if APNS::ERROR_CODES.include? error_code
        raise APNS::Error, APNS::ERROR_CODES[error_code]
      else
        raise APNS::Error, 'Unknown error code'
      end
    end
  end
end
