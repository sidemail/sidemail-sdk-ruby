# frozen_string_literal: true

RSpec.describe Sidemail::Resource do
  let(:data) { { "id" => "123", "nested" => { "foo" => "bar" }, "list" => [{ "a" => 1 }] } }
  let(:resource) { described_class.new(data) }

  it "allows access via hash key" do
    expect(resource["id"]).to eq("123")
  end

  it "allows access via method call" do
    expect(resource.id).to eq("123")
  end

  it "wraps nested hashes" do
    expect(resource.nested).to be_a(Sidemail::Resource)
    expect(resource.nested.foo).to eq("bar")
  end

  it "wraps items in lists" do
    expect(resource.list.first).to be_a(Sidemail::Resource)
    expect(resource.list.first.a).to eq(1)
  end

  it "returns raw hash via to_h" do
    expect(resource.to_h).to eq(data)
  end

  it "returns raw hash via raw" do
    expect(resource.raw).to eq(data)
  end

  it "stringifies using to_s and inspect" do
    expect(resource.to_s).to eq(data.to_s)
    expect(resource.inspect).to eq(data.inspect)
  end

  it "responds to keys as methods" do
    expect(resource.respond_to?(:id)).to be true
    expect(resource.respond_to?(:missing)).to be false
  end

  it "raises NoMethodError for missing keys" do
    expect { resource.missing }.to raise_error(NoMethodError)
  end
end
