# frozen_string_literal: true

require_relative "resource"

module Sidemail
  class PaginatedResponse
    include Enumerable

    attr_reader :has_more, :pagination_cursor_next, :pagination_cursor_prev, :raw

    def initialize(response_body, client, path, params, method)
      @raw = response_body
      @items = (response_body["data"] || []).map { |item| Resource.new(item) }
      @has_more = response_body["hasMore"]
      @pagination_cursor_next = response_body["paginationCursorNext"]
      @pagination_cursor_prev = response_body["paginationCursorPrev"]
      @client = client
      @path = path
      @params = params
      @method = method
    end

    def inspect
      @raw.inspect
    end

    def to_s
      @raw.to_s
    end

    def [](key)
      @raw[key.to_s]
    end

    def method_missing(method_name, *args, &block)
      if @raw.key?(method_name.to_s)
        @raw[method_name.to_s]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @raw.key?(method_name.to_s) || super
    end

    def items
      @items
    end

    def data
      @items
    end

    def each(&block)
      return to_enum(:each) unless block_given?
      
      @items.each do |item|
        yield item
      end
    end

    def auto_paginate
      return to_enum(:auto_paginate) unless block_given?

      # Yield current page items
      each { |item| yield item }

      current_cursor = @pagination_cursor_next
      
      while current_cursor
        # Fetch next page
        next_params = @params.dup
        if @method == :get
          next_params[:paginationCursorNext] = current_cursor
        else
          next_params["paginationCursorNext"] = current_cursor
        end

        response = @client.perform_request(@path, params: next_params, method: @method)
        
        # Yield items from the new page
        if response["data"]
          response["data"].each { |item| yield Resource.new(item) }
        end

        current_cursor = response["paginationCursorNext"]
        break unless response["hasMore"]
      end
    end
  end
end
