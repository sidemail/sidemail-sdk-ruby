# frozen_string_literal: true

module Sidemail
  module Resources
    class Project
      def initialize(client)
        @client = client
      end

      def create(params)
        response = @client.perform_request("project", params: params, method: :post)
        Resource.new(response)
      end

      def get
        response = @client.perform_request("project", method: :get)
        Resource.new(response)
      end

      def update(params)
        response = @client.perform_request("project", params: params, method: :patch)
        Resource.new(response)
      end

      def delete
        response = @client.perform_request("project", method: :delete)
        Resource.new(response)
      end
    end
  end
end
