# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Courses::Copy do
  let(:original_course_enrichments) { create(:course_enrichment) }
  let(:original_course) { create(:course, enrichments: [original_course_enrichments], accept_pending_gcse: true) }

  let(:new_course_enrichments) { create(:course_enrichment, course_length: nil, about_course: nil) }
  let(:new_course) { create(:course, enrichments: [new_course_enrichments], accept_pending_gcse: nil) }

  let(:blank_course_enrichments) { create(:course_enrichment, course_length: nil, about_course: nil) }
  let(:course_with_blank_enrichments) { create(:course, enrichments: [blank_course_enrichments]) }

  let(:fields_to_copy) { [['Salary details', 'salary_details'], ['About the course', 'about_course']] }

  describe '.get_present_fields_in_source_course' do
    it 'updates the enrichment attributes for present source values' do
      expect(new_course.enrichments.first.course_length).to be_nil
      expect(new_course.enrichments.first.about_course).to be_nil

      described_class.get_present_fields_in_source_course(fields_to_copy, original_course, new_course)

      expect(new_course.enrichments.first.about_course).to eq original_course.enrichments.first.about_course
      expect(new_course.enrichments.first.salary_details).to eq original_course.enrichments.first.salary_details
    end

    it 'skips attributes with blank source values' do
      expect(new_course.enrichments.first.course_length).to be_nil
      expect(new_course.enrichments.first.about_course).to be_nil

      described_class.get_present_fields_in_source_course(fields_to_copy, course_with_blank_enrichments, new_course)

      expect(new_course.enrichments.first.course_length).to be_nil
      expect(new_course.enrichments.first.about_course).to be_nil
    end
  end

  describe '.get_boolean_fields' do
    it 'updates the boolean fields with source values' do
      expect(new_course.accept_pending_gcse).to be_nil

      described_class.get_boolean_fields(Courses::Copy::GCSE_FIELDS, original_course, new_course)

      expect(new_course.accept_pending_gcse).to be true
    end
  end
end
