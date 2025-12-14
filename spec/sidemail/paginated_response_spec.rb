# frozen_string_literal: true

RSpec.describe Sidemail::PaginatedResponse do
  let(:client) { instance_double(Sidemail::Client) }
  let(:first_page_data) do
    {
      "data" => [{ "id" => 1 }, { "id" => 2 }],
      "hasMore" => true,
      "paginationCursorNext" => "cursor_2",
      "paginationCursorPrev" => nil
    }
  end
  let(:second_page_data) do
    {
      "data" => [{ "id" => 3 }],
      "hasMore" => false,
      "paginationCursorNext" => nil,
      "paginationCursorPrev" => "cursor_1"
    }
  end

  let(:paginated_response) do
    described_class.new(first_page_data, client, "test", {}, :get)
  end

  describe "#initialize" do
    it "sets attributes correctly" do
      expect(paginated_response.items.size).to eq(2)
      expect(paginated_response.items.first).to be_a(Sidemail::Resource)
      expect(paginated_response.has_more).to be true
      expect(paginated_response.pagination_cursor_next).to eq("cursor_2")
    end
  end

  describe "#each" do
    it "iterates over items in the current page" do
      ids = []
      paginated_response.each { |item| ids << item.id }
      expect(ids).to eq([1, 2])
    end

    it "wraps items in Resource" do
      paginated_response.each do |item|
        expect(item).to be_a(Sidemail::Resource)
      end
    end
  end

  describe "#auto_paginate" do
    it "fetches subsequent pages and yields all items" do
      allow(client).to receive(:perform_request)
        .with("test", params: { paginationCursorNext: "cursor_2" }, method: :get)
        .and_return(second_page_data)

      ids = []
      paginated_response.auto_paginate.each { |item| ids << item.id }
      
      expect(ids).to eq([1, 2, 3])
    end

    it "handles POST requests pagination" do
      post_response = described_class.new(first_page_data, client, "test", {}, :post)
      
      allow(client).to receive(:perform_request)
        .with("test", params: { "paginationCursorNext" => "cursor_2" }, method: :post)
        .and_return(second_page_data)

      ids = []
      post_response.auto_paginate.each { |item| ids << item.id }
      
      expect(ids).to eq([1, 2, 3])
    end
  end

  describe "delegation" do
    it "delegates missing methods to raw response" do
      expect(paginated_response["hasMore"]).to be true
    end

    it "exposes items via data alias" do
      expect(paginated_response.data.map(&:id)).to eq([1, 2])
    end

    it "delegates method calls to raw response via method_missing" do
      expect(paginated_response.hasMore).to be true
      expect(paginated_response.respond_to?(:hasMore)).to be true
      expect(paginated_response.respond_to?(:missing_key)).to be false
      expect { paginated_response.missing_key }.to raise_error(NoMethodError)
    end

    it "returns enumerators when no block is given" do
      # each enumerator
      enum = paginated_response.each
      expect(enum).to be_a(Enumerator)
      expect(enum.map(&:id)).to eq([1, 2])

      # auto_paginate enumerator
      allow(client).to receive(:perform_request)
        .with("test", params: { paginationCursorNext: "cursor_2" }, method: :get)
        .and_return(second_page_data)

      auto_enum = paginated_response.auto_paginate
      expect(auto_enum).to be_a(Enumerator)
      expect(auto_enum.map(&:id)).to eq([1, 2, 3])
    end

    it "implements to_s and inspect based on raw" do
      expect(paginated_response.to_s).to eq(first_page_data.to_s)
      expect(paginated_response.inspect).to eq(first_page_data.inspect)
    end

    it "handles pages without data key" do
      empty_page = {
        "hasMore" => false,
        "paginationCursorNext" => nil,
        "paginationCursorPrev" => "cursor_1"
      }

      allow(client).to receive(:perform_request)
        .with("test", params: { paginationCursorNext: "cursor_2" }, method: :get)
        .and_return(empty_page)

      ids = []
      paginated_response.auto_paginate.each { |item| ids << item.id }

      # Only items from the first page should be yielded
      expect(ids).to eq([1, 2])
    end
  end
end
