# frozen_string_literal: true

require_relative "../lib/mls/mailerstats"


describe MLS::MailerStats do

  before do
    @mailerstats = MLS::MailerStats.new(api_url: "foo")
  end

  it "can create a mailer stats report from retrieved data" do
    response = '{ "Data" : [{ "DeliveredCount" : 7 }] }'

    @mailerstats.stub(:request_json_data, response) do
      @mailerstats.get.must_match /\ASent emails today: +7\Z/
    end
  end
end
