# frozen_string_literal: true

module Sidemail
  module Resources
    class Contact
      def initialize(client)
        @client = client
      end

      def create_or_update(params)
        raise Sidemail::Error.new("Missing contact data") unless params
        response = @client.perform_request("contacts", params: params, method: :post)
        Resource.new(response)
      end

      def find(email_address)
        raise Sidemail::Error.new("Missing emailAddress") unless email_address
        response = @client.perform_request("contacts/#{email_address}", method: :get)
        Resource.new(response)
      end

      def list(params = {})
        response = @client.perform_request("contacts", params: params, method: :get)
        PaginatedResponse.new(response, @client, "contacts", params, :get)
      end
      
      def query(params = {})
        list(params)
      end

      def delete(email_address)
        response = @client.perform_request("contacts/#{email_address}", method: :delete)
        Resource.new(response)
      end
    end
  end
end
