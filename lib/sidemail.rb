# frozen_string_literal: true

require_relative "sidemail/version"
require_relative "sidemail/error"
require_relative "sidemail/client"

module Sidemail
  class << self
    attr_accessor :api_key

    def new(api_key: nil, **options)
      Client.new(api_key: api_key || self.api_key, **options)
    end

    def file_to_attachment(name, content)
      {
        name: name,
        content: Base64.strict_encode64(content)
      }
    end
  end
end
