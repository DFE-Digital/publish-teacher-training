# frozen_string_literal: true

require 'rails_helper'

describe WorkflowStepService do
  subject do
    described_class.call(course)
  end

  describe '#call' do
    context 'when course.is_school_direct? && when course.provider.accredited_bodies.length == 0' do
      let(:provider) do
        build(
          :provider,
          accrediting_provider_enrichments:
        )
      end
      let(:course) { create(:course, accrediting_provider: accredited_provider, provider:) }
      let(:accrediting_provider_enrichments) { nil }
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

    context 'when course.is_school_direct? && course.provider.accredited_bodies.length == 1' do
      let(:provider) do
        build(
          :provider,
          accrediting_provider_enrichments:
        )
      end
      let(:course) { create(:course, accrediting_provider: accredited_provider, provider:) }
      let(:accrediting_provider_enrichments) { [{ 'Description' => 'Something great about the accredited provider', 'UcasProviderCode' => accredited_provider.provider_code }] }
      let(:accredited_provider) { build(:provider, :accredited_provider) }

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
      let(:provider) do
        build(
          :provider,
          accrediting_provider_enrichments:
        )
      end
      let(:course) { create(:course, :resulting_in_undergraduate_degree_with_qts, provider:) }
      let(:accrediting_provider_enrichments) { [{ 'Description' => 'Something great about the accredited provider', 'UcasProviderCode' => accredited_provider.provider_code }, { 'Description' => 'some description', 'UcasProviderCode' => second_accredited_provider.provider_code }] }
      let(:accredited_provider) { build(:provider, :accredited_provider) }
      let(:second_accredited_provider) { build(:provider, :accredited_provider) }

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
      let(:provider) do
        build(
          :provider,
          accrediting_provider_enrichments:
        )
      end
      let(:course) { create(:course, :resulting_in_undergraduate_degree_with_qts, accrediting_provider: accredited_provider, provider:) }
      let(:accrediting_provider_enrichments) { [{ 'Description' => 'Something great about the accredited provider', 'UcasProviderCode' => accredited_provider.provider_code }] }
      let(:accredited_provider) { build(:provider, :accredited_provider) }

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
    let(:course) { create(:course, provider:) }

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
