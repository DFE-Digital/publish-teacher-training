# frozen_string_literal: true

require 'rails_helper'

describe Publish::CourseInterviewProcessForm, type: :model do
  describe 'validations' do
    it 'validates length' do
      course = create(:course)
      enrichment = course.enrichments.find_or_initialize_draft
      valid_interview_process = Faker::Lorem.sentence(word_count: 249)
      invalid_interview_process = Faker::Lorem.sentence(word_count: 251)

      expect(described_class.new(enrichment, params: { interview_process: valid_interview_process }).valid?).to be true
      expect(described_class.new(enrichment, params: { interview_process: nil }).valid?).to be true
      expect(described_class.new(enrichment, params: { interview_process: invalid_interview_process }).valid?).to be false
    end
  end

  describe '#save!' do
    it 'saves valid interview_process values' do
      course = create(:course)
      enrichment = course.enrichments.find_or_initialize_draft

      [nil, 'some value'].each do |value|
        described_class.new(enrichment, params: { interview_process: value }).save!
        expect(enrichment.reload.interview_process).to eq value
      end
    end
  end
end
