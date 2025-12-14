# frozen_string_literal: true

RSpec.describe Sidemail do
  it "has a version number" do
    expect(Sidemail::VERSION).not_to be nil
  end

  describe ".new" do
    it "creates a new client" do
      client = Sidemail.new(api_key: "test")
      expect(client).to be_a(Sidemail::Client)
      expect(client.api_key).to eq("test")
    end

    it "uses global api_key if not provided" do
      Sidemail.api_key = "global_key"
      client = Sidemail.new
      expect(client.api_key).to eq("global_key")
      Sidemail.api_key = nil # cleanup
    end
  end

  describe ".file_to_attachment" do
    it "converts content to base64 attachment hash" do
      content = "hello world"
      attachment = Sidemail.file_to_attachment("test.txt", content)
      
      expect(attachment[:name]).to eq("test.txt")
      expect(attachment[:content]).to eq(Base64.strict_encode64(content))
    end
  end
end
