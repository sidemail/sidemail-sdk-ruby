# frozen_string_literal: true

module Sidemail
  module Resources
    class Messenger
      def initialize(client)
        @client = client
      end

      def list(params = {})
        response = @client.perform_request("messenger", params: params, method: :get)
        PaginatedResponse.new(response, @client, "messenger", params, :get)
      end

      def get(id)
        response = @client.perform_request("messenger/#{id}", method: :get)
        Resource.new(response)
      end

      def create(params)
        response = @client.perform_request("messenger", params: params, method: :post)
        Resource.new(response)
      end

      def update(id, params)
        response = @client.perform_request("messenger/#{id}", params: params, method: :patch)
        Resource.new(response)
      end

      def delete(id)
        response = @client.perform_request("messenger/#{id}", method: :delete)
        Resource.new(response)
      end
    end
  end
end
