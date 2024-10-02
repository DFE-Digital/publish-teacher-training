# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Publish::Courses::AssignTdaAttributesService do
  subject(:service) { described_class.new(course) }

  let(:course) do
    create(
      :course,
      study_mode: 'part_time',
      funding: 'fee',
      can_sponsor_skilled_worker_visa: true,
      can_sponsor_student_visa: true,
      degree_type:
    )
  end

  describe '#call' do
    let(:degree_type) { 'undergraduate' }

    context 'when course does not have enrichments' do
      it 'updates the course attributes and returns true' do
        expect(service.call).to be_truthy
        expect(course.study_mode).to eq('full_time')
        expect(course.funding).to eq('apprenticeship')
        expect(course.can_sponsor_skilled_worker_visa).to be(false)
        expect(course.can_sponsor_student_visa).to be(false)
        expect(course.additional_degree_subject_requirements).to be(false)
        expect(course.degree_subject_requirements).to be_nil
        expect(course.degree_grade).to eq('not_required')
        expect(course.degree_type).to eq('undergraduate')
      end
    end

    context 'when course is postgraduate and contain fees' do
      let(:degree_type) { 'postgraduate' }
      let!(:enrichment) do
        build(
          :course_enrichment,
          :initial_draft,
          fee_uk_eu: 9200,
          fee_international: 9000,
          fee_details: 'Some details'
        ).tap do |course_enrichment|
          course.enrichments << course_enrichment
        end
      end

      it 'updates fee details to nil' do
        expect(service.call).to be_truthy
        expect(course.degree_type).to eq('undergraduate')
        enrichment.reload
        expect(enrichment.fee_uk_eu).to be_nil
        expect(enrichment.fee_details).to be_nil
        expect(enrichment.fee_international).to be_nil
      end
    end
  end
end
