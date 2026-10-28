# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support add user wizard", travel: mid_cycle do
  include DfESignInUserHelper

  let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }

  before do
    host! URI(Settings.base_url).host
    login_user(create(:user, :admin))
  end

  it "shows the entered details and only creates the user when confirmed" do
    get new_support_recruitment_cycle_user_path(recruitment_cycle.year)
    expect(response).to redirect_to(%r{/support/#{recruitment_cycle.year}/users/wizard/.+/details})
    follow_redirect!

    state_key = response.request.fullpath[%r{wizard/([^/]+)/details}, 1]

    patch wizard_support_recruitment_cycle_users_path(recruitment_cycle.year, state_key:, step: :details), params: {
      details: {
        first_name: "ysysy",
        last_name: "ssgs",
        email: "  sgs@sdgsg.com  ",
        admin: "false",
      },
    }

    expect(response).to redirect_to(
      wizard_support_recruitment_cycle_users_path(recruitment_cycle.year, state_key:, step: :check_answers),
    )
    expect(User.find_by(email: "sgs@sdgsg.com")).to be_nil

    follow_redirect!

    expect(response.body).to include("Check your answers")
    expect(response.body).to include("ysysy")
    expect(response.body).to include("ssgs")
    expect(response.body).to include("sgs@sdgsg.com")
    expect(response.body).to include("The user will be sent an email to tell them you’ve added them to the organisation.")
    expect(response.body).to include("Add user")

    patch wizard_support_recruitment_cycle_users_path(recruitment_cycle.year, state_key:, step: :check_answers)

    expect(response).to redirect_to(support_recruitment_cycle_users_path(recruitment_cycle.year))
    follow_redirect!
    expect(response.body).to include("User added")
    expect(User.find_by(email: "sgs@sdgsg.com")).to be_present
    expect(User.find_by(email: "sgs@sdgsg.com").admin).to be false
  end
end
