# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Blazer" do
  it "can reach the database its data source points at" do
    # A URL Blazer cannot connect to breaks the whole suite rather than just
    # Blazer: it registers the pool, and setup_transactional_fixtures then pins
    # every registered pool in every later example. Blazer stays quiet about it,
    # rescuing the failure and rendering its query page anyway, so assert on the
    # connection here.
    result = Blazer.data_sources["main"].run_statement("SELECT 1 AS one")

    expect(result.error).to be_nil
    expect(result.rows).to eq([[1]])
  end
end
