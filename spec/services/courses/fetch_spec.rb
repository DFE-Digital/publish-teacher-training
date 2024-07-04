# frozen_string_literal: true

require 'rails_helper'

describe Courses::Fetch do
  describe '.by_code' do
    let(:provider_code) { course.provider.provider_code }
    let(:course_code) { course.course_code }
    let(:recruitment_cycle_year) { course.recruitment_cycle.year }
    let(:course) { create(:course) }

    it 'fetches a course by course_code' do
      expect(described_class.by_code(
               provider_code:,
               course_code:,
               recruitment_cycle_year:
             )).to eq(course)
    end
  end

  describe '.by_accrediting_provider_dynamically_sorted_list' do
    context 'when sorting alphabetically by course name' do
      let(:provider) { build(:provider, courses: [course_a, course_b, course_c]) }
      let(:course_a) { build(:course, name: 'a') }
      let(:course_b) { build(:course, name: 'b') }
      let(:course_c) { build(:course, name: 'c') }

      it 'sorts courses in ascending order' do
        sorted_courses = described_class.by_accrediting_provider_dynamically_sorted_list(provider, sort: 'course', direction: 'ascending')
        expect(sorted_courses.values.flatten).to eq([course_a, course_b, course_c])
      end

      it 'sorts courses in descending order' do
        sorted_courses = described_class.by_accrediting_provider_dynamically_sorted_list(provider, sort: 'course', direction: 'descending')
        expect(sorted_courses.values.flatten).to eq([course_c, course_b, course_a])
      end
    end

    context 'when sorting by status' do
      let(:provider) { build(:provider, courses: [draft_course, open_course, closed_course, withdrawn_course, rolled_over_course, published_with_unpublished_changes_course]) }
      let(:open_course) { build(:course, :open, :published) }
      let(:closed_course) { build(:course, :closed, :published) }
      let(:withdrawn_course) { build(:course, :withdrawn) }
      let(:draft_course) { build(:course, enrichments: [build(:course_enrichment, :draft)]) }
      let(:rolled_over_course) { build(:course, enrichments: [build(:course_enrichment, :rolled_over)]) }
      let(:published_with_unpublished_changes_course) { build(:course, enrichments: [build(:course_enrichment, :subsequent_draft)]) }

      it 'sorts courses by content_status and application_status in the correct ascending order' do
        sorted_courses = described_class.by_accrediting_provider_dynamically_sorted_list(provider, sort: 'status', direction: 'ascending')
        expect(sorted_courses.values.flatten).to eq([draft_course, rolled_over_course, published_with_unpublished_changes_course, open_course, closed_course, withdrawn_course])
      end

      it 'sorts courses by content_status and application_status in descending order' do
        sorted_courses = described_class.by_accrediting_provider_dynamically_sorted_list(provider, sort: 'status', direction: 'descending')
        expect(sorted_courses.values.flatten).to eq([withdrawn_course, closed_course, open_course, published_with_unpublished_changes_course, rolled_over_course, draft_course])
      end
    end
  end
end
