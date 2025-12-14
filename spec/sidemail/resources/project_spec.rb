# frozen_string_literal: true

RSpec.describe Sidemail::Resources::Project do
  let(:client) { instance_double(Sidemail::Client) }
  let(:project_resource) { described_class.new(client) }

  describe "#create" do
    it "creates a project" do
      params = { name: "New Project" }
      expect(client).to receive(:perform_request).with("project", params: params, method: :post).and_return({ "id" => "123" })
      
      response = project_resource.create(params)
      expect(response.id).to eq("123")
    end
  end

  describe "#get" do
    it "retrieves a project" do
      expect(client).to receive(:perform_request).with("project", method: :get).and_return({ "id" => "123" })
      
      response = project_resource.get
      expect(response.id).to eq("123")
    end
  end

  describe "#update" do
    it "updates a project" do
      params = { name: "Updated Name" }
      expect(client).to receive(:perform_request).with("project", params: params, method: :patch).and_return({ "id" => "123" })
      
      response = project_resource.update(params)
      expect(response.id).to eq("123")
    end
  end

  describe "#delete" do
    it "deletes a project" do
      expect(client).to receive(:perform_request).with("project", method: :delete).and_return({ "deleted" => true })
      
      response = project_resource.delete
      expect(response.deleted).to be true
    end
  end
end
