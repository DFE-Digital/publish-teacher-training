# frozen_string_literal: true

require "rails_helper"

describe "Publish::Providers::TrainingPartners::CoursesController#index" do
  include DfESignInUserHelper

  def count_queries(&)
    count = 0
    counter = ->(_name, _start, _finish, _id, payload) { count += 1 unless payload[:name].to_s =~ /SCHEMA|TRANSACTION/ }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &)
    count
  end

  def render_list_of(course_count)
    accredited_provider = create(:provider, :accredited_provider)
    user = create(:user, providers: [accredited_provider])
    training_partner = create(:provider)
    create(:provider_partnership, training_provider: training_partner, accredited_provider: accredited_provider)
    create_list(:course, course_count, :published_postgraduate, provider: training_partner, accrediting_provider: accredited_provider)

    login_user(user)
    count_queries do
      get "/publish/organisations/#{accredited_provider.provider_code}/#{accredited_provider.recruitment_cycle_year}/training-partners/#{training_partner.provider_code}/courses"
    end
  end

  # The View course column asks every row whether it is running, which reads site
  # statuses. Bullet does not raise in test, so this is what stops that becoming
  # a query per course.
  it "renders the list in a constant number of queries regardless of course count" do
    many = render_list_of(9)
    few = render_list_of(3)

    expect(response.body).to include("View live course")
    expect(many).to eq(few)
  end
end
