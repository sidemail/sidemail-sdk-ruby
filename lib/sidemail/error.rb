# frozen_string_literal: true

module Sidemail
  class Error < StandardError
    attr_reader :http_status, :error_code, :more_info

    def initialize(message, http_status: nil, error_code: nil, more_info: nil)
      super(message)
      @http_status = http_status
      @error_code = error_code
      @more_info = more_info
    end
  end
end
