require 'rails_helper'

RSpec.describe Call, type: :model do
  fixtures :users

  before do
    stub_twilio_request
  end

  it 'extracts phone numbers on create' do
    call = Call.create(from_user: users(:earnie), to_user: users(:bert))
    expect(call.from_number).to match(/\+1\d{10}/)
    expect(call.to_number).to match(/\+1\d{10}/)
  end

  it 'connects the call when created' do
    call = Call.create(from_user: users(:earnie), to_user: users(:bert))

    assert_requested :post, "https://api.twilio.com/2010-04-01/Accounts/#{ENV['TWILIO_ACCOUNT_SID']}/Calls.json",
      body: {
        "From" => ENV['TWILIO_PHONE_NUMBER'],
        "To"   => call.from_number,
        "Url"  => call.url
      }
  end

  def stub_twilio_request
    stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/#{ENV['TWILIO_ACCOUNT_SID']}/Calls.json")
        .with(body: {
          "From" => ENV['TWILIO_PHONE_NUMBER'],
          "To"   => /\+1\d{10}/,
          "Url"  => %r(http://www.test.com/calls/\d+)
        })
        .to_return(status: 201, body: "", headers: {})
  end

end
