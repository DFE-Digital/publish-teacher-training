# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AssignProgramType' do
  describe Courses::AssignProgramTypeService do
    describe '#execute' do
      let(:service) { described_class.new }

      context 'a self accredited course' do
        subject { create(:course, :self_accredited) }

        it 'does not error course object when updated to salaried course' do
          subject.update(program_type: 'school_direct_salaried_training_programme')
          expect(subject.errors.count).to eq 0
        end
      end

      context 'when funding type is salary' do
        let(:funding_type) { 'salary' }

        it 'sets the correct program type for SCITT providers' do
          provider = create(:provider, :scitt)
          course = create(:course, provider:, funding_type:)
          service.execute(funding_type, course)

          expect(course.program_type).to eq('scitt_salaried_programme')
        end

        it 'sets the correct program type for university providers' do
          provider = create(:provider, :university)
          course = create(:course, provider:, funding_type:)
          service.execute(funding_type, course)
          expect(course.program_type).to eq('higher_education_salaried_programme')
        end

        it 'sets the correct program type for lead school providers' do
          provider = create(:provider, :lead_school)
          course = create(:course, provider:, funding_type:)
          service.execute(funding_type, course)
          expect(course.program_type).to eq('school_direct_salaried_training_programme')
        end
      end

      context 'when funding type is apprenticeship' do
        let(:funding_type) { 'apprenticeship' }

        it 'sets the program type to pg_teaching_apprenticeship' do
          provider = create(:provider)
          course = create(:course, provider:, funding_type:)
          service.execute(funding_type, course)
          expect(course.program_type).to eq('pg_teaching_apprenticeship')
        end
      end

      context 'when funding type is fee' do
        let(:funding_type) { 'fee' }

        it 'sets the correct program type for externally accredited courses' do
          provider = create(:provider, :lead_school)
          course = create(:course, funding_type:, provider:)
          service.execute(funding_type, course)
          expect(course.program_type).to eq('school_direct_training_programme')
        end

        it 'sets the correct program type for SCITT courses' do
          provider = create(:provider, :scitt)
          course = create(:course, provider:, funding_type:)
          service.execute(funding_type, course)
          expect(course.program_type).to eq('scitt_programme')
        end

        it 'sets the correct program type for HEI self-accredited courses' do
          provider = create(:provider, :university)
          course = create(:course, :with_accrediting_provider, provider:, funding_type:)
          service.execute(funding_type, course)
          expect(course.program_type).to eq('higher_education_programme')
        end
      end
    end
  end
end
