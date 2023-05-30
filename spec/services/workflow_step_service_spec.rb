# frozen_string_literal: true

require 'rails_helper'

describe WorkflowStepService do
  let(:accredited_provider) { build(:provider, :accredited_provider) }

  let(:provider) do
    build(
      :provider,
      :lead_school,
      provider_name: 'Provider 1',
      accrediting_provider_enrichments: [{
        'Description' => 'Something great about the accredited provider',
        'UcasProviderCode' => accredited_provider.provider_code
      }]
    )
  end
  
  subject do
    described_class.call(course)
    end

  describe '#call' do
    context 'when course.provider.lead_school? && course.provider.accredited_bodies.length == 1' do
    let(:course) { create(:course, accrediting_provider: accredited_provider, provider: provider) }
      it 'returns the expected workflow steps' do
        expected_steps = [
          :courses_list,
          :level,
          :subjects,
          :engineers_teach_physics,
          :modern_languages,
          :age_range,
          :outcome,
          :funding_type,
          :full_or_part_time,
          :school,
          :can_sponsor_student_visa,
          :can_sponsor_skilled_worker_visa,
          :applications_open,
          :start_date,
          :confirmation
        ]

        expect(subject).to eq(expected_steps)
      end
    end

    # context 'when course.is_further_education?' do
    # let(:course) { create(:course, :further_education) }
    # it 'returns the expected workflow steps' do
    #     expected_steps = [
    #       :courses_list,
    #       :level,
    #       :outcome,
    #       :full_or_part_time,
    #       :school,
    #       :applications_open,
    #       :start_date,
    #       :confirmation
    #     ]

    #     expect(subject).to eq(expected_steps)
    #   end        
    # end

    # context 'when course.is_uni_or_scitt?' do
    #     binding.pry
    #     let(:course) { create(:course, :uni_or_scitt) }
  
    #     it 'returns the expected workflow steps' do
    #       expected_steps = [
    #         :courses_list,
    #         :level,
    #         :subjects,
    #         :engineers_teach_physics,
    #         :modern_languages,
    #         :age_range,
    #         :outcome,
    #         :apprenticeship,
    #         :full_or_part_time,
    #         :school,
    #         :can_sponsor_student_visa,
    #         :can_sponsor_skilled_worker_visa,
    #         :applications_open,
    #         :start_date,
    #         :confirmation
    #       ]
  
    #       expect(subject).to eq(expected_steps)
    #     end
    #   end
  end
end
