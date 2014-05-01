require "net/http"
require "json"

class MLMailerStats

  def initialize(options)
    @api_url = options[:api_url].dup
    @api_url << "/"  unless @api_url[-1] == "/"

    @api_key = options[:api_key]
  end

  def get
    stats = extract_stats

    info = "Sent emails\n"
    info << "last 24 hours: %4d\n" % stats[:today]
    info << "last  7 days:  %4d\n" % stats[:last_7_days]
    info << "last 30 days:  %4d\n" % stats[:last_30_days]
    info << "\n"
    info << "backlog:       %4d\n" % stats[:backlog]

    info
  end

  private

  def extract_stats
    data = get_user_info

    stats = {}
    stats[:backlog] = data["backlog"]

    data_stats = data["stats"]
    if data_stats
      stats[:today]        = data_stats["today"]["sent"]
      stats[:last_7_days]  = data_stats["last_7_days"]["sent"]
      stats[:last_30_days] = data_stats["last_30_days"]["sent"]
    end

    stats
  end

  def get_user_info
    uri = URI.parse(@api_url + "users/info.json")
    request = Net::HTTP::Post.new(uri)
    request.body = {"key" => @api_key}.to_json

    res = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.ssl_version = :SSLv3
      http.request request
    end

    if res.is_a? Net::HTTPSuccess
      JSON.parse(res.body)
    else
      {}
    end
  end
end
