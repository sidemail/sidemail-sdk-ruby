# frozen_string_literal: true

RSpec.describe Sidemail::Resources::Messenger do
  let(:client) { instance_double(Sidemail::Client) }
  let(:messenger_resource) { described_class.new(client) }

  describe "#list" do
    it "lists messengers" do
      response_data = { "data" => [], "hasMore" => false }
      expect(client).to receive(:perform_request).with("messenger", params: {}, method: :get).and_return(response_data)
      
      response = messenger_resource.list
      expect(response).to be_a(Sidemail::PaginatedResponse)
    end
  end

  describe "#get" do
    it "retrieves a messenger" do
      expect(client).to receive(:perform_request).with("messenger/123", method: :get).and_return({ "id" => "123" })
      
      response = messenger_resource.get("123")
      expect(response.id).to eq("123")
    end
  end

  describe "#create" do
    it "creates a messenger" do
      params = { subject: "Hello" }
      expect(client).to receive(:perform_request).with("messenger", params: params, method: :post).and_return({ "id" => "123" })
      
      response = messenger_resource.create(params)
      expect(response.id).to eq("123")
    end
  end

  describe "#update" do
    it "updates a messenger" do
      params = { subject: "Updated" }
      expect(client).to receive(:perform_request).with("messenger/123", params: params, method: :patch).and_return({ "id" => "123" })
      
      response = messenger_resource.update("123", params)
      expect(response.id).to eq("123")
    end
  end

  describe "#delete" do
    it "deletes a messenger" do
      expect(client).to receive(:perform_request).with("messenger/123", method: :delete).and_return({ "deleted" => true })
      
      response = messenger_resource.delete("123")
      expect(response.deleted).to be true
    end
  end
end
