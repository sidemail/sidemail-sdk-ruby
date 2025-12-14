# frozen_string_literal: true

RSpec.describe Sidemail::Client do
  let(:api_key) { "test_api_key" }
  let(:client) { described_class.new(api_key: api_key) }
  let(:base_url) { "https://api.sidemail.io/v1" }

  describe "#initialize" do
    it "sets the api_key" do
      expect(client.api_key).to eq(api_key)
    end

    it "sets default base_url" do
      expect(client.base_url).to eq(base_url)
    end

    it "allows overriding base_url" do
      client = described_class.new(api_key: api_key, base_url: "https://example.com")
      expect(client.base_url).to eq("https://example.com")
    end

    it "sets timeout" do
      client = described_class.new(api_key: api_key, timeout: 10.0)
      expect(client.timeout).to eq(10.0)
    end

    it "sets http_client" do
      http_client = double("http_client")
      client = described_class.new(api_key: api_key, http_client: http_client)
      expect(client.http_client).to eq(http_client)
    end

    it "raises error if api_key is missing" do
      expect { described_class.new(api_key: nil) }.to raise_error(Sidemail::Error, /apiKey missing/)
    end

    it "reads from ENV if api_key is not provided" do
      allow(ENV).to receive(:[]).with("SIDEMAIL_API_KEY").and_return("env_key")
      client = described_class.new
      expect(client.api_key).to eq("env_key")
    end
  end

  describe "resources" do
    it "returns email resource" do
      expect(client.email).to be_a(Sidemail::Resources::Email)
    end

    it "returns contacts resource" do
      expect(client.contacts).to be_a(Sidemail::Resources::Contact)
    end

    it "returns project resource" do
      expect(client.project).to be_a(Sidemail::Resources::Project)
    end

    it "returns messenger resource" do
      expect(client.messenger).to be_a(Sidemail::Resources::Messenger)
    end

    it "returns domains resource" do
      expect(client.domains).to be_a(Sidemail::Resources::Domain)
    end
  end

  describe "#send_email" do
    it "delegates to email resource" do
      params = { toAddress: "test@example.com" }
      expect(client.email).to receive(:send).with(params)
      client.send_email(params)
    end
  end

  describe "#perform_request" do
    it "makes a GET request" do
      stub_request(:get, "#{base_url}/test")
        .with(headers: { "Authorization" => "Bearer #{api_key}" })
        .to_return(status: 200, body: '{"foo": "bar"}', headers: { "Content-Type" => "application/json" })

      response = client.perform_request("test", method: :get)
      expect(response).to eq({ "foo" => "bar" })
    end

    it "uses custom http_client if provided" do
      http_client = double("http_client")
      client = described_class.new(api_key: api_key, http_client: http_client)
      
      response_obj = instance_double(Net::HTTPResponse, body: '{"foo": "bar"}', code: "200", message: "OK")
      allow(response_obj).to receive(:[]) .with("content-type").and_return("application/json")
      allow(response_obj).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

      expect(http_client).to receive(:request).and_return(response_obj)

      response = client.perform_request("test", method: :get)
      expect(response).to eq({ "foo" => "bar" })
    end

    it "sets timeout on http client" do
      client = described_class.new(api_key: api_key, timeout: 5.0)
      
      stub_request(:get, "#{base_url}/test")
        .to_return(status: 200, body: '{}', headers: { "Content-Type" => "application/json" })

      # We can't easily spy on Net::HTTP.new instances without more complex mocking, 
      # but we can verify the request succeeds with the option set.
      # Alternatively, we can mock Net::HTTP.new
      
      http_double = instance_double(Net::HTTP)
      allow(Net::HTTP).to receive(:new).and_return(http_double)
      allow(http_double).to receive(:use_ssl=)
      expect(http_double).to receive(:read_timeout=).with(5.0)
      expect(http_double).to receive(:open_timeout=).with(5.0)
      expect(http_double).to receive(:request).and_return(
        instance_double(Net::HTTPResponse, body: '{}', code: "200", message: "OK", :[] => "application/json", is_a?: true)
      )

      client.perform_request("test")
    end

    it "makes a POST request with body" do
      params = { foo: "bar" }
      stub_request(:post, "#{base_url}/test")
        .with(
          body: params.to_json,
          headers: { "Authorization" => "Bearer #{api_key}" }
        )
        .to_return(status: 200, body: '{"success": true}', headers: { "Content-Type" => "application/json" })

      response = client.perform_request("test", params: params, method: :post)
      expect(response).to eq({ "success" => true })
    end

    it "makes a DELETE request" do
      stub_request(:delete, "#{base_url}/delete_me")
        .with(headers: { "Authorization" => "Bearer #{api_key}" })
        .to_return(status: 200, body: '{}', headers: { "Content-Type" => "application/json" })

      response = client.perform_request("delete_me", method: :delete)
      expect(response).to eq({})
    end

    it "makes a PATCH request with body" do
      params = { foo: "baz" }
      stub_request(:patch, "#{base_url}/patch_me")
        .with(
          body: params.to_json,
          headers: { "Authorization" => "Bearer #{api_key}" }
        )
        .to_return(status: 200, body: '{"patched": true}', headers: { "Content-Type" => "application/json" })

      response = client.perform_request("patch_me", params: params, method: :patch)
      expect(response).to eq({ "patched" => true })
    end

    it "handles query parameters for GET requests" do
      stub_request(:get, "#{base_url}/test?foo=bar")
        .to_return(status: 200, body: '{}', headers: { "Content-Type" => "application/json" })

      client.perform_request("test", params: { foo: "bar" }, method: :get)
    end

    it "raises Sidemail::Error on API error" do
      stub_request(:get, "#{base_url}/error")
        .to_return(
          status: 400, 
          body: '{"developerMessage": "Bad Request", "errorCode": "invalid_param", "moreInfo": "info"}', 
          headers: { "Content-Type" => "application/json" }
        )

      expect {
        client.perform_request("error", method: :get)
      }.to raise_error(Sidemail::Error) do |e|
        expect(e.message).to eq("Bad Request")
        expect(e.http_status).to eq(400)
        expect(e.error_code).to eq("invalid_param")
        expect(e.more_info).to eq("info")
      end
    end

    it "raises Sidemail::Error on non-JSON error with empty body" do
      stub_request(:get, "#{base_url}/error")
        .to_return(status: [500, "Server Error"], body: "")

      expect {
        client.perform_request("error", method: :get)
      }.to raise_error(Sidemail::Error) do |e|
        expect(e.message).to eq("Server Error")
        expect(e.http_status).to eq(500)
      end
    end

    it "returns raw body for non-JSON success responses" do
      stub_request(:get, "#{base_url}/text")
        .to_return(status: 200, body: "OK", headers: { "Content-Type" => "text/plain" })

      response = client.perform_request("text", method: :get)
      expect(response).to eq("OK")
    end

    it "raises ArgumentError for unknown method" do
      expect {
        client.perform_request("test", method: :invalid)
      }.to raise_error(ArgumentError, /Unknown method/)
    end
  end
end
