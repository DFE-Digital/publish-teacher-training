# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Find - Root path", service: :find do
  include DfESignInUserHelper

  it "shows the find page" do
    visit "/"
    expect(page).to have_content("Find teacher training courses in England")
  end
end
