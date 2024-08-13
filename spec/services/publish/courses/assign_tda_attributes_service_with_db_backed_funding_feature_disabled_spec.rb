# This file can be deleted along with the db_backed_funding_type feature flag. All functionality is tested in
# spec/services/publish/courses/assign_tda_attributes_service_spec.rb

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Publish::Courses::AssignTdaAttributesService do
  let(:course) { create(:course, study_mode: 'part_time', funding_type: 'fee', can_sponsor_skilled_worker_visa: true, can_sponsor_student_visa: true) }

  before do
    allow(Settings.features).to receive(:db_backed_funding_type).and_return(false)
  end

  describe '#call' do
    it 'updates the course attributes and returns true' do
      expect(described_class.new(course).call).to be_truthy
      expect(course.study_mode).to eq('full_time')
      expect(course.funding_type).to eq('apprenticeship')
      expect(course.can_sponsor_skilled_worker_visa).to be(false)
      expect(course.can_sponsor_student_visa).to be(false)
      expect(course.additional_degree_subject_requirements).to be(false)
      expect(course.degree_subject_requirements).to be_nil
      expect(course.degree_grade).to eq('not_required')
      expect(course.course_type).to eq('undergraduate')
    end
  end
end
