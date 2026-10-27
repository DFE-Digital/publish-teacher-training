# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support manual provider rollover" do
  include DfESignInUserHelper

  let(:provider) { create(:provider) }
  let(:admin) { create(:user, :admin) }

  before do
    host! URI(Settings.base_url).host
    login_user(admin)
    create(:recruitment_cycle, :next) unless provider.recruitment_cycle.next
  end

  describe "GET /support/:recruitment_cycle_year/providers/:provider_id/manual_rollover" do
    # Schools are counted from Provider::School, so the summary is right for a
    # provider whose schools were never mirrored into the legacy site table.
    it "counts the schools the provider will roll over" do
      create_list(:provider_school, 2, provider:)

      get manual_rollover_support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider)

      expect(response).to have_http_status(:ok)
      expect(schools_summary_row).to have_text("2")
    end

    it "counts the study sites, which are still only in the legacy site table" do
      create_list(:site, 3, :study_site, provider:)

      get manual_rollover_support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider)

      expect(response).to have_http_status(:ok)
      expect(study_sites_summary_row).to have_text("3")
    end

    def schools_summary_row
      Capybara.string(response.body).find(".govuk-summary-list__row", text: "Number of schools")
    end

    def study_sites_summary_row
      Capybara.string(response.body).find(".govuk-summary-list__row", text: "Number of study sites")
    end
  end

  describe "POST /support/:recruitment_cycle_year/providers/:provider_id/manual_rollover_confirm" do
    let(:previous_recruitment_cycle) { find_or_create(:recruitment_cycle, :previous) }
    let(:current_recruitment_cycle) { find_or_create(:recruitment_cycle) }
    let(:provider) { create(:provider, recruitment_cycle: previous_recruitment_cycle) }
    let!(:chosen_course) { create(:course, provider:) }
    let!(:other_course) { create(:course, provider:) }

    it "rolls a provider that missed rollover into the next cycle with only the chosen courses" do
      confirm_rollover(course_codes: ["", chosen_course.course_code])

      expect(response).to redirect_to(support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider))
      expect(rolled_over_provider.courses.pluck(:course_code)).to eq([chosen_course.course_code])
    end

    it "rolls the provider without courses when no courses is chosen" do
      confirm_rollover(course_codes: ["", Support::Providers::ManualRolloverForm::NO_COURSES])

      expect(rolled_over_provider).to be_present
      expect(rolled_over_provider.courses).to be_empty
    end

    it "rolls nothing over and says which course failed when a chosen course cannot be copied" do
      allow(Courses::CopyToProviderService).to receive(:new).and_wrap_original do |original, **kwargs|
        original.call(**kwargs).tap { allow(it).to receive(:execute).and_raise(StandardError, "copy failed") }
      end

      confirm_rollover(course_codes: ["", chosen_course.course_code])

      expect(Capybara.string(response.body)).to have_css(".govuk-error-summary", text: "Nothing was rolled over because #{chosen_course.course_code} could not be copied")
      expect(rolled_over_provider).to be_nil
    end

    it "does not roll over a provider that is already in the next cycle" do
      create(:provider, provider_code: provider.provider_code, recruitment_cycle: current_recruitment_cycle)

      confirm_rollover(course_codes: ["", chosen_course.course_code])

      expect(response).to redirect_to(support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider))
      expect(rolled_over_provider.courses).to be_empty
    end

    def confirm_rollover(course_codes:)
      post manual_rollover_confirm_support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider), params: {
        support_providers_manual_rollover_form: {
          confirmation: Support::Providers::ManualRolloverForm::CONFIRM_ROLLOVER,
          environment: Settings.environment.name,
          course_codes:,
        },
      }
    end

    def rolled_over_provider
      current_recruitment_cycle.providers.find_by(provider_code: provider.provider_code)
    end
  end
end
