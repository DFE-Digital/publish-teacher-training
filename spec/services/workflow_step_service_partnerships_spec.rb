# frozen_string_literal: true

require 'rails_helper'

describe WorkflowStepService do
  subject do
    described_class.call(course)
  end

  before do
    allow(Settings.features).to receive(:provider_partnerships).and_return(true)
  end

  describe '#call partnerships' do
    context 'when course.is_school_direct? && when course.provider.accredited_partners.length == 0' do
      let(:provider) { build(:provider) }
      let(:course) { create(:course, :salary) }
      let(:accredited_provider) { nil }

      it 'returns the expected workflow steps' do
        expected_steps = %i[
          courses_list
          level
          subjects
          engineers_teach_physics
          modern_languages
          age_range
          outcome
          funding_type
          full_or_part_time
          school
          study_site
          accredited_provider
          can_sponsor_skilled_worker_visa
          applications_open
          start_date
          confirmation
        ]

        expect(subject).to eq(expected_steps)
      end
    end

    context 'when course.is_school_direct? && course.provider.accredited_partners.length == 1' do
      let(:provider) { build(:provider, :with_accredited_partner) }
      let(:course) { create(:course, :salary, accrediting_provider: accredited_provider, provider:) }
      let(:accredited_provider) { provider.accredited_partners.first }

      it 'returns the expected workflow steps' do
        expected_steps = %i[
          courses_list
          level
          subjects
          engineers_teach_physics
          modern_languages
          age_range
          outcome
          funding_type
          full_or_part_time
          school
          study_site
          can_sponsor_skilled_worker_visa
          applications_open
          start_date
          confirmation
        ]

        expect(subject).to eq(expected_steps)
      end
    end
  end

  context 'when school direct and teacher degree apprenticeship' do
    context 'when more than one accredited provider' do
      let(:provider) { build(:provider) }
      let(:course) { create(:course, :resulting_in_undergraduate_degree_with_qts, provider:) }
      let!(:partnerships) { create_list(:provider_partnership, 2, training_provider: provider) }
      let(:accredited_provider) { provider.accredited_partners.first }
      let(:second_accredited_provider) { provider.accredited_partners.last }

      it 'adds accredited provider step' do
        expected_steps = %i[
          courses_list
          level
          subjects
          engineers_teach_physics
          modern_languages
          age_range
          outcome
          school
          study_site
          accredited_provider
          applications_open
          start_date
          confirmation
        ]

        expect(subject).to eq(expected_steps)
      end
    end

    context 'when only one accredited provider' do
      let(:provider) { build(:provider, :with_accredited_partner) }
      let(:accredited_provider) { provider.accredited_partners.first }
      let(:course) { create(:course, :resulting_in_undergraduate_degree_with_qts, accrediting_provider: accredited_provider, provider:) }

      it 'removes accredited provider step' do
        expected_steps = %i[
          courses_list
          level
          subjects
          engineers_teach_physics
          modern_languages
          age_range
          outcome
          school
          study_site
          applications_open
          start_date
          confirmation
        ]

        expect(subject).to eq(expected_steps)
      end
    end
  end

  context 'when scitt and teacher degree apprenticeship' do
    let(:provider) { create(:provider, :scitt, :accredited_provider) }
    let(:course) { create(:course, :resulting_in_undergraduate_degree_with_qts, provider:) }

    it 'returns workflow steps' do
      expected_steps = %i[
        courses_list
        level
        subjects
        engineers_teach_physics
        modern_languages
        age_range
        outcome
        school
        study_site
        applications_open
        start_date
        confirmation
      ]

      expect(subject).to eq(expected_steps)
    end
  end

  context 'when course.is_further_education?' do
    let(:provider) { create(:provider, :accredited_provider) }

    let(:course) { create(:course, provider:, level: 'further_education', subjects: [find_or_create(:further_education_subject)]) }

    it 'returns the expected workflow steps' do
      expected_steps = %i[
        courses_list
        level
        outcome
        funding_type
        full_or_part_time
        school
        study_site
        applications_open
        start_date
        confirmation
      ]

      expect(subject).to eq(expected_steps)
    end
  end

  context 'when course.is_uni_or_scitt?' do
    let(:provider) { create(:provider, :accredited_provider) }
    let(:course) { create(:course, :salary, provider:) }

    it 'returns the expected workflow steps' do
      expected_steps = %i[
        courses_list
        level
        subjects
        engineers_teach_physics
        modern_languages
        age_range
        outcome
        funding_type
        full_or_part_time
        school
        study_site
        can_sponsor_skilled_worker_visa
        applications_open
        start_date
        confirmation
      ]

      expect(subject).to eq(expected_steps)
    end
  end
end
