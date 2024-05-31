# frozen_string_literal: true

require 'rails_helper'

describe Publish::CourseSchoolPlacementsForm, type: :model do
  describe 'validations' do
    it 'validates length' do
      course = create(:course)
      enrichment = course.enrichments.find_or_initialize_draft
      valid_input = Faker::Lorem.sentence(word_count: 349)
      invalid_input = Faker::Lorem.sentence(word_count: 351)

      expect(described_class.new(enrichment, params: { how_school_placements_work: valid_input }).valid?).to be true
      expect(described_class.new(enrichment, params: { how_school_placements_work: invalid_input }).valid?).to be false
    end

    it 'validates presence' do
      course = create(:course)
      enrichment = course.enrichments.find_or_initialize_draft

      expect(described_class.new(enrichment, params: { how_school_placements_work: nil }).valid?).to be false
    end
  end

  describe '#save!' do
    it 'saves with valid input' do
      course = create(:course)
      enrichment = course.enrichments.find_or_initialize_draft
      valid_input = Faker::Lorem.sentence(word_count: 349)

      described_class.new(enrichment, params: { how_school_placements_work: valid_input }).save!
      expect(enrichment.reload.how_school_placements_work).to eq valid_input
    end
  end
end
