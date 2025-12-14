# frozen_string_literal: true

module Sidemail
  module Resources
    class Domain
      def initialize(client)
        @client = client
      end

      def list(params = {})
        response = @client.perform_request("domains", params: params, method: :get)
        PaginatedResponse.new(response, @client, "domains", params, :get)
      end

      def create(params)
        response = @client.perform_request("domains", params: params, method: :post)
        Resource.new(response)
      end

      def delete(id)
        response = @client.perform_request("domains/#{id}", method: :delete)
        Resource.new(response)
      end
    end
  end
end
