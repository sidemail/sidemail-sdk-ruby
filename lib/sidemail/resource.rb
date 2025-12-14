# frozen_string_literal: true

module Sidemail
  class Resource
    def initialize(data)
      @data = data
    end

    def [](key)
      value = @data[key.to_s]
      wrap(value)
    end

    def to_h
      @data
    end

    def raw
      @data
    end

    def inspect
      @data.inspect
    end

    def to_s
      @data.to_s
    end

    def method_missing(method_name, *args, &block)
      key = method_name.to_s
      if @data.key?(key)
        wrap(@data[key])
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @data.key?(method_name.to_s) || super
    end

    private

    def wrap(value)
      if value.is_a?(Hash)
        Resource.new(value)
      elsif value.is_a?(Array)
        value.map { |v| wrap(v) }
      else
        value
      end
    end
  end
end
