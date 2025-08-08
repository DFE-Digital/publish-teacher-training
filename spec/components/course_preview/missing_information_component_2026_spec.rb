# frozen_string_literal: true

require "rails_helper"

module CoursePreview
  describe MissingInformationComponent, type: :component do
    include Rails.application.routes.url_helpers

    context "when the course is incomplete" do
      let(:provider) { build(:provider) }
      let(:accrediting_provider) { build(:provider) }
      let(:course) { Course.new(provider:, course_code:, accrediting_provider:) }
      let(:provider_code) { provider.provider_code }
      let(:recruitment_cycle_year) { provider.recruitment_cycle_year }
      let(:course_code) { "4GET" }

      let(:hrefs) do
        {
          train_with_disability: edit_publish_provider_recruitment_cycle_disability_support_path(provider_code, recruitment_cycle_year, course_code:, goto_training_with_disabilities: true),
          train_with_us: edit_publish_provider_recruitment_cycle_why_train_with_us_path(provider_code, recruitment_cycle_year, course_code:, goto_provider: true),
        }
      end

      before do
        Current.recruitment_cycle = RecruitmentCycle.last
      end

      shared_examples "course with missing information" do |information_type, text|
        it "renders link for missing #{information_type}" do
          Current.recruitment_cycle = create(:recruitment_cycle, :next)
          Timecop.travel Time.local(2025, 11, 1) do
            render_inline(described_class.new(course:, information_type:, is_preview: true))

            expect(page).to have_link(text, href: hrefs[information_type])
          end
        end
      end

      include_examples "course with missing information", :train_with_us, "Enter details about the training provider"
      include_examples "course with missing information", :train_with_disability, "Enter details about training with disabilities and other needs"
    end
  end
end
