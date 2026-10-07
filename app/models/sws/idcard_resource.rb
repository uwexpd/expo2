class IdcardResource < WebServiceResult
  IDCARD_VERSION = "v1"

  class ForbiddenError < StandardError; end
  class RequestError < StandardError; end

  self.element_path = "idcard/#{IDCARD_VERSION}/card"
  self.cache_lifetime = 0.seconds

  class << self
    def headers
      {
        "x-uw-act-as" => "expo",
        "Accept" => "application/json"
      }
    end

    # Accept the reader's 14-character hexadecimal UID; IDCARD expects its decimal value.
    def find_by_prox_rfid(hex_uid)
      uid = hex_uid.to_s.strip
      unless uid.match?(/\A[0-9a-f]{14}\z/i)
        raise ArgumentError, "RFID UID must be 14 hexadecimal characters"
      end

      decimal_rfid = uid.to_i(16).to_s
      path = "#{element_path}.json?#{URI.encode_www_form(prox_rfid: decimal_rfid)}"
      Rails.logger.info("[RFID] IDCARD card lookup requested")

      response = connection.get(path)

      case response
      when 403, 30
        raise ForbiddenError, "IDCARD SWS returned 403 Forbidden"
      when Integer
        raise RequestError, "IDCARD SWS returned HTTP #{response}"
      end

      JSON.parse(response)
    end
  end
end
