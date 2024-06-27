# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ALevelEquivalenciesStore do
  subject(:store) { described_class.new(wizard) }

  let(:course) { create(:course) }
  let(:provider) { build(:provider) }
  let(:current_step) { :a_level_equivalencies }
  let(:step_params) { {} }

  let(:wizard) do
    ALevelsWizard.new(
      current_step:,
      provider:,
      course:,
      step_params: ActionController::Parameters.new(
        { current_step => ActionController::Parameters.new(step_params) }
      )
    )
  end

  describe '#save' do
    it 'updates course with accept_a_level_equivalency as true and additional_a_level_equivalencies' do
      step_params.merge!(
        accept_a_level_equivalency: 'yes',
        additional_a_level_equivalencies: 'Some additional info'
      )
      store.save
      course.reload

      expect(course.accept_a_level_equivalency).to be true
      expect(course.additional_a_level_equivalencies).to eq('Some additional info')
    end

    it 'updates course with accept_a_level_equivalency as true and additional_a_level_equivalencies as nil when additional info is blank' do
      step_params.merge!(
        accept_a_level_equivalency: 'yes',
        additional_a_level_equivalencies: ''
      )
      store.save
      course.reload

      expect(course.accept_a_level_equivalency).to be true
      expect(course.additional_a_level_equivalencies).to be_nil
    end

    it 'updates course with accept_a_level_equivalency as false and additional_a_level_equivalencies as nil' do
      step_params.merge!(
        accept_a_level_equivalency: 'no',
        additional_a_level_equivalencies: 'Some additional info'
      )
      store.save
      course.reload

      expect(course.accept_a_level_equivalency).to be false
      expect(course.additional_a_level_equivalencies).to be_nil
    end
  end
end
