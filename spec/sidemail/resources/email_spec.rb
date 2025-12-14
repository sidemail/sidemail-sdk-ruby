# frozen_string_literal: true

RSpec.describe Sidemail::Resources::Email do
  let(:client) { instance_double(Sidemail::Client) }
  let(:email_resource) { described_class.new(client) }

  describe "#send" do
    it "sends an email" do
      params = { toAddress: "test@example.com" }
      expect(client).to receive(:perform_request).with("email/send", params: params, method: :post).and_return({ "id" => "123" })
      
      response = email_resource.send(params)
      expect(response.id).to eq("123")
    end
  end

  describe "#search" do
    it "searches emails" do
      params = { query: { status: "delivered" } }
      response_data = { "data" => [], "hasMore" => false }
      expect(client).to receive(:perform_request).with("email/search", params: params, method: :post).and_return(response_data)
      
      response = email_resource.search(params)
      expect(response).to be_a(Sidemail::PaginatedResponse)
    end
  end

  describe "#get" do
    it "retrieves an email" do
      expect(client).to receive(:perform_request).with("email/123", method: :get).and_return({ "id" => "123" })
      
      response = email_resource.get("123")
      expect(response.id).to eq("123")
    end
  end

  describe "#delete" do
    it "deletes an email" do
      expect(client).to receive(:perform_request).with("email/123", method: :delete).and_return({ "deleted" => true })
      
      response = email_resource.delete("123")
      expect(response.deleted).to be true
    end
  end
end
