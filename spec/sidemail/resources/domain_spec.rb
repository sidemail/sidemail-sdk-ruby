# frozen_string_literal: true

RSpec.describe Sidemail::Resources::Domain do
  let(:client) { instance_double(Sidemail::Client) }
  let(:domain_resource) { described_class.new(client) }

  describe "#list" do
    it "lists domains" do
      response_data = { "data" => [], "hasMore" => false }
      expect(client).to receive(:perform_request).with("domains", params: {}, method: :get).and_return(response_data)
      
      response = domain_resource.list
      expect(response).to be_a(Sidemail::PaginatedResponse)
    end
  end

  describe "#create" do
    it "creates a domain" do
      params = { name: "example.com" }
      expect(client).to receive(:perform_request).with("domains", params: params, method: :post).and_return({ "id" => "123" })
      
      response = domain_resource.create(params)
      expect(response.id).to eq("123")
    end
  end

  describe "#delete" do
    it "deletes a domain" do
      expect(client).to receive(:perform_request).with("domains/123", method: :delete).and_return({ "deleted" => true })
      
      response = domain_resource.delete("123")
      expect(response.deleted).to be true
    end
  end
end
