# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module MLS

  # Retrieves mailer stats via API.
  class MailerStats

    def initialize(options)
      @api_url = options[:api_url]
      @api_key = options[:api_key]
      @user, @pwd = @api_key.split(":")  if @api_key
    end

    def get
      "Sent emails today: %3d\n" % delivered_count
    end

    private

    def delivered_count
      data = JSON.parse(request_json_data)

      data["Data"].first["DeliveredCount"]
    end

    def request_json_data
      uri = URI(@api_url)
      ssl_options = { use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_PEER }

      Net::HTTP.start(uri.host, uri.port, ssl_options) do |http|
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(@user, @pwd)
        response = http.request(request)

        msg = "Unable to retrieve mailer stats data (code #{response.code})"
        raise msg  unless response.is_a?(Net::HTTPSuccess)

        response.body
      end
    end
  end
end
