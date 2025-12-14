# frozen_string_literal: true

module Sidemail
  module Resources
    class Email
      def initialize(client)
        @client = client
      end

      def send(params)
        response = @client.perform_request("email/send", params: params, method: :post)
        Resource.new(response)
      end

      def search(params = {})
        response = @client.perform_request("email/search", params: params, method: :post)
        PaginatedResponse.new(response, @client, "email/search", params, :post)
      end

      def get(id)
        response = @client.perform_request("email/#{id}", method: :get)
        Resource.new(response)
      end

      def delete(id)
        response = @client.perform_request("email/#{id}", method: :delete)
        Resource.new(response)
      end
    end
  end
end
