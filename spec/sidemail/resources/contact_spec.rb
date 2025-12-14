# frozen_string_literal: true

RSpec.describe Sidemail::Resources::Contact do
  let(:client) { instance_double(Sidemail::Client) }
  let(:contact_resource) { described_class.new(client) }

  describe "#create_or_update" do
    it "creates or updates a contact" do
      params = { emailAddress: "test@example.com" }
      expect(client).to receive(:perform_request).with("contacts", params: params, method: :post).and_return({ "id" => "123" })
      
      response = contact_resource.create_or_update(params)
      expect(response.id).to eq("123")
    end

    it "raises error if params are missing" do
      expect { contact_resource.create_or_update(nil) }.to raise_error(Sidemail::Error, "Missing contact data")
    end
  end

  describe "#find" do
    it "finds a contact" do
      expect(client).to receive(:perform_request).with("contacts/test@example.com", method: :get).and_return({ "emailAddress" => "test@example.com" })
      
      response = contact_resource.find("test@example.com")
      expect(response.emailAddress).to eq("test@example.com")
    end

    it "raises error if email is missing" do
      expect { contact_resource.find(nil) }.to raise_error(Sidemail::Error, "Missing emailAddress")
    end
  end

  describe "#list" do
    it "lists contacts" do
      response_data = { "data" => [], "hasMore" => false }
      expect(client).to receive(:perform_request).with("contacts", params: {}, method: :get).and_return(response_data)
      
      response = contact_resource.list
      expect(response).to be_a(Sidemail::PaginatedResponse)
    end
  end

  describe "#query" do
    it "queries contacts (alias for list)" do
      params = { query: { "customProps.plan" => "pro" } }
      response_data = { "data" => [], "hasMore" => false }
      expect(client).to receive(:perform_request).with("contacts", params: params, method: :get).and_return(response_data)
      
      response = contact_resource.query(params)
      expect(response).to be_a(Sidemail::PaginatedResponse)
    end
  end

  describe "#delete" do
    it "deletes a contact" do
      expect(client).to receive(:perform_request).with("contacts/test@example.com", method: :delete).and_return({ "deleted" => true })
      
      response = contact_resource.delete("test@example.com")
      expect(response.deleted).to be true
    end
  end
end
