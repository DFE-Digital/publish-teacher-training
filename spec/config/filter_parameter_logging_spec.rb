# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Parameter filtering" do
  let(:filter) { ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters) }
  let(:secret) { create(:api_key).secret }

  it "masks an API key under a param name the name filters miss, however it is written" do
    params = { key: secret, nested: { value: "before #{secret} after" }, list: [secret], encoded: secret.sub("_", "%5F") }

    expect(filter.filter(params)).to eq(
      key: "[FILTERED]",
      nested: { value: "[FILTERED]" },
      list: ["[FILTERED]"],
      encoded: "[FILTERED]",
    )
  end

  it "leaves an ordinary value untouched" do
    params = { key: "ptt_not-a-real-key", other: 1 }

    expect(filter.filter(params)).to eq(params)
  end
end
