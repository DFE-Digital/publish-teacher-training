# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Find::UniversityDegreeStatusForm do
  describe 'validations' do
    it 'is valid when university_degree_status is present' do
      form = described_class.new(university_degree_status: 'true')
      expect(form).to be_valid
    end

    it 'is not valid when university_degree_status is not present' do
      form = described_class.new(university_degree_status: nil)
      expect(form).not_to be_valid
      expect(form.errors[:university_degree_status]).to include(
        'Select whether you have a university degree'
      )
    end
  end
end
