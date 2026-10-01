# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::Public::V1::Providers::CoursesController#index", service: :api do
  # The serialiser reads every course's status, site statuses, enrichment
  # fields and ratifying provider, so the search service has to preload them.
  # The controller picks a different search service either side of the
  # schools remodel, so both are covered whichever cycle is current.
  {
    "before the schools remodel" => Settings.schools_remodel_cycle_year,
    "after the schools remodel" => Settings.schools_remodel_cycle_year + 1,
  }.each do |period, year|
    context "for a provider in the #{year} cycle, #{period}" do
      let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year:) }
      let(:provider) { create(:provider, recruitment_cycle:) }
      let(:accredited_provider) { create(:accredited_provider, recruitment_cycle:) }

      def render_courses_for(course_count)
        create_list(:course, course_count, :published, :with_full_time_sites, provider:, accredited_provider_code: accredited_provider.provider_code)

        count_queries do
          get "/api/public/v1/recruitment_cycles/#{recruitment_cycle.year}/providers/#{provider.provider_code}/courses",
              params: { include: "accredited_body" }
        end
      end

      it "serialises the courses in a constant number of queries regardless of course count" do
        # The first request also pays one-off lookups that later requests
        # reuse, so it is left out of the comparison.
        render_courses_for(1)

        few = render_courses_for(2)
        many = render_courses_for(3)

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["data"].size).to eq(6)
        expect(many).to eq(few)
      end
    end
  end
end
