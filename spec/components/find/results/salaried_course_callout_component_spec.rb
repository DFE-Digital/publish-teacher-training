# frozen_string_literal: true

require "rails_helper"

module Find
  module Results
    describe SalariedCourseCalloutComponent, type: :component do
      include Rails.application.routes.url_helpers

      let(:physics) { find_or_create(:secondary_subject, :physics, bursary_amount: "29000") }
      let(:history) { find_or_create(:secondary_subject, :history) }
      let(:primary) { find_or_create(:primary_subject, :primary_with_mathematics) }

      before { FeatureFlag.activate(:bursaries_and_scholarships_announced) }

      def render_callout(funding:, subject_codes: [physics.subject_code])
        render_inline(described_class.new(funding:, subject_codes:))
      end

      context "with a secondary subject that has a bursary or scholarship" do
        [
          [nil, false],
          [%w[fee], false],
          [%w[salary], true],
          [%w[apprenticeship], true],
          [%w[fee salary], true],
          [%w[fee apprenticeship], true],
          [%w[salary apprenticeship], true],
          [%w[fee salary apprenticeship], true],
        ].each do |funding, shown|
          it "#{shown ? 'renders' : 'does not render'} when funding is #{funding.inspect}" do
            render_callout(funding:)

            if shown
              expect(page).to have_css(".app-callout", text: "Is a salaried course right for me?")
            else
              expect(page).to have_no_css(".app-callout")
            end
          end
        end
      end

      it "renders the content with a tracked link to Get Into Teaching" do
        render_callout(funding: %w[salary])

        expect(page).to have_css("h2", text: "Is a salaried course right for me?")
        expect(page).to have_text(
          "Fee paying courses are less competitive, and you could receive more money if you're a UK citizen and eligible for bursaries or scholarships.",
        )
        expect(page).to have_link(
          "bursaries or scholarships",
          href: find_track_click_path(
            url: "https://getintoteaching.education.gov.uk/funding-and-support/scholarships-and-bursaries",
            utm_content: "results_salaried_course_callout_bursaries_and_scholarships",
          ),
        )
      end

      it "renders when an eligible subject is selected alongside an ineligible one" do
        render_callout(funding: %w[salary], subject_codes: [history.subject_code, physics.subject_code])

        expect(page).to have_css(".app-callout")
      end

      it "does not render for a secondary subject without a bursary or scholarship" do
        render_callout(funding: %w[salary], subject_codes: [history.subject_code])

        expect(page).to have_no_css(".app-callout")
      end

      it "does not render for a primary subject" do
        create(:financial_incentive, subject: primary, bursary_amount: "29000")

        render_callout(funding: %w[salary], subject_codes: [primary.subject_code])

        expect(page).to have_no_css(".app-callout")
      end

      it "does not render when no subject is selected" do
        render_callout(funding: %w[salary], subject_codes: [])

        expect(page).to have_no_css(".app-callout")
      end

      it "does not render when bursaries and scholarships have not been announced" do
        FeatureFlag.deactivate(:bursaries_and_scholarships_announced)

        render_callout(funding: %w[salary])

        expect(page).to have_no_css(".app-callout")
      end
    end
  end
end
