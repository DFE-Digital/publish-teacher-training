# frozen_string_literal: true

require "rails_helper"

RSpec.describe RolloverProviderJob do
  describe "#perform" do
    let(:new_recruitment_cycle) do
      find_or_create(:recruitment_cycle, :next)
    end
    let(:provider) do
      create(:provider)
    end

    it "copy courses from specific provider only" do
      courses = create_list(:course, 5, :published, provider:)
      create_list(:course, 5, :published, provider: create(:provider))

      subject.perform(provider.provider_code, new_recruitment_cycle.id)

      expect(new_recruitment_cycle.courses.pluck(:name, :course_code)).to match_array(
        courses.pluck(:name, :course_code),
      )
    end
  end
end
