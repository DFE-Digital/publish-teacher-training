require "rails_helper"

describe "Seed" do
  before do
    SecondarySubject.clear_cache
  end

  it "seeds without error" do
    # https://stackoverflow.com/questions/38483820/testing-successful-seed-with-minitest-rspec
    expect { load Rails.root.join("db/seeds.rb") }.not_to raise_error
  end
end
