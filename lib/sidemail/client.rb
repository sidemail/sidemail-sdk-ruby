# frozen_string_literal: true

require "net/http"
require "json"
require "uri"
require "base64"
require_relative "paginated_response"
require_relative "resources/email"
require_relative "resources/contact"
require_relative "resources/project"
require_relative "resources/messenger"
require_relative "resources/domain"

module Sidemail
	class Client
		DEFAULT_BASE_URL = "https://api.sidemail.io/v1"

		attr_reader :api_key, :base_url, :timeout, :http_client

		def initialize(api_key: nil, base_url: DEFAULT_BASE_URL, timeout: nil, http_client: nil)
			@api_key = api_key || ENV["SIDEMAIL_API_KEY"]
			raise Sidemail::Error.new("apiKey missing. Provide it as an option or set SIDEMAIL_API_KEY environment variable.") unless @api_key
			@base_url = base_url
			@timeout = timeout
			@http_client = http_client
		end

		def email
			@email ||= Resources::Email.new(self)
		end

		def contacts
			@contacts ||= Resources::Contact.new(self)
		end

		def project
			@project ||= Resources::Project.new(self)
		end
    
		def messenger
			@messenger ||= Resources::Messenger.new(self)
		end

		def domains
			@domains ||= Resources::Domain.new(self)
		end

		def send_email(params)
			email.send(params)
		end

		def perform_request(path, params: nil, method: :get)
			base = @base_url.end_with?("/") ? @base_url : "#{@base_url}/"
			uri = URI.parse("#{base}#{path}")
      
			if method == :get && params
				# Add query params
				existing_query = URI.decode_www_form(uri.query || "")
				new_query = existing_query + params.map { |k, v| [k.to_s, v] }
				uri.query = URI.encode_www_form(new_query)
			end

			http = if @http_client
							 @http_client
						 else
							 client = Net::HTTP.new(uri.host, uri.port)
							 client.use_ssl = (uri.scheme == "https")
							 if @timeout
								 client.read_timeout = @timeout
								 client.open_timeout = @timeout
							 end
							 client
						 end
      
			request = case method
								when :get
									Net::HTTP::Get.new(uri)
								when :post
									Net::HTTP::Post.new(uri)
								when :delete
									Net::HTTP::Delete.new(uri)
								when :patch
									Net::HTTP::Patch.new(uri)
								else
									raise ArgumentError, "Unknown method: #{method}"
								end

			request["Authorization"] = "Bearer #{@api_key}"
			request["Content-Type"] = "application/json"
			request["User-Agent"] = "sidemail-sdk-ruby/#{Sidemail::VERSION}"

			if [:post, :patch].include?(method) && params
				request.body = params.to_json
			end

			response = http.request(request)
      
			content_type = response["content-type"]
      
			if content_type && content_type.include?("application/json")
				body = JSON.parse(response.body)
			else
				body = response.body
			end

			unless response.is_a?(Net::HTTPSuccess)
				message = if body.is_a?(Hash)
										body["developerMessage"]
									else
										body.to_s.empty? ? response.message : body
									end
				error_code = body.is_a?(Hash) ? body["errorCode"] : nil
				more_info = body.is_a?(Hash) ? body["moreInfo"] : nil
        
				raise Sidemail::Error.new(
					message, 
					http_status: response.code.to_i,
					error_code: error_code,
					more_info: more_info
				)
			end

			body
		end
	end
end
