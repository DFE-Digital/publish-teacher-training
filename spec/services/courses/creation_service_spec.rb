# frozen_string_literal: true

require 'rails_helper'

describe Courses::CreationService do
  subject do
    described_class.call(
      course_params: valid_course_params, provider:,
      next_available_course_code:
    )
  end

  let(:provider) { create(:provider, sites: [site], study_sites: [study_site]) }

  let(:site) { build(:site) }
  let(:study_site) { build(:site, :study_site) }

  let(:recruitment_cycle) { provider.recruitment_cycle }

  let(:next_available_course_code) { false }

  context 'visa sponsorship is duplicated in params' do
    context 'when funding is fee' do
      let(:valid_course_params) do
        {
          'level' => 'primary',
          'can_sponsor_skilled_worker_visa' => 'true',
          'can_sponsor_student_visa' => 'true',
          'funding' => 'fee',
          'qualification' => 'pgde'
        }
      end

      it 'cannot sponsor skilled workers visas' do
        expect(subject.can_sponsor_student_visa).to be(true)
        expect(subject.can_sponsor_skilled_worker_visa).to be(false)
      end
    end

    context 'when funding is salary' do
      let(:valid_course_params) do
        {
          'level' => 'primary',
          'can_sponsor_skilled_worker_visa' => 'true',
          'can_sponsor_student_visa' => 'true',
          'funding' => 'salary',
          'qualification' => 'pgde'
        }
      end

      it 'cannot sponsor skilled workers visas' do
        expect(subject.can_sponsor_student_visa).to be(false)
        expect(subject.can_sponsor_skilled_worker_visa).to be(true)
      end
    end

    context 'when funding is apprenticeship' do
      let(:valid_course_params) do
        {
          'level' => 'primary',
          'can_sponsor_skilled_worker_visa' => 'true',
          'can_sponsor_student_visa' => 'true',
          'funding' => 'apprenticeship',
          'qualification' => 'pgde'
        }
      end

      it 'cannot sponsor skilled workers visas' do
        expect(subject.can_sponsor_student_visa).to be(false)
        expect(subject.can_sponsor_skilled_worker_visa).to be(true)
      end
    end
  end

  context 'when teacher degree apprenticeship course' do
    let(:valid_course_params) do
      {
        'level' => 'primary',
        'is_send' => '1',
        'age_range_in_years' => '3_to_7',
        'qualification' => 'undergraduate_degree_with_qts'
      }
    end

    it 'creates the teacher degree apprenticeship course' do
      expect(subject.program_type).to eq('teacher_degree_apprenticeship')
      expect(subject.funding).to eq('apprenticeship')
      expect(subject.can_sponsor_student_visa?).to be false
      expect(subject.can_sponsor_skilled_worker_visa?).to be false
      expect(subject.additional_degree_subject_requirements).to be(false)
      expect(subject.degree_grade).to eq('not_required')
      expect(subject.enrichments.last).to be_present
      expect(subject.enrichments.last.course_length).to eq('4 years')
    end
  end

  context 'primary course' do
    let(:primary_subject) { find_or_create(:primary_subject, :primary) }

    let(:valid_course_params) do
      {
        'age_range_in_years' => '3_to_7',
        'applications_open_from' => recruitment_cycle.application_start_date,
        'funding' => 'fee',
        'is_send' => '1',
        'level' => 'primary',
        'qualification' => 'qts',
        'start_date' => "September #{recruitment_cycle.year}",
        'study_mode' => ['full_time'],
        'sites_ids' => [site.id],
        'study_sites_ids' => [study_site.id],
        'master_subject_id' => primary_subject.id,
        'subjects_ids' => [primary_subject.id],
        'course_code' => 'D0CK'
      }
    end

    it 'create the primary course' do
      valid_course_params.except('is_send', 'sites_ids', 'study_sites_ids', 'subjects_ids', 'course_code', 'study_mode').each do |key, value|
        expect(subject.public_send(key)).to eq(value)
      end

      expect(subject.is_send).to be(true)
      expect(subject.sites.map(&:id)).to eq([site.id])
      expect(subject.study_sites.map(&:id)).to eq([study_site.id])
      expect(subject.course_subjects.map { it.subject.id }).to eq([primary_subject.id])
      expect(subject.course_code).to be_nil
      expect(subject.name).to eq('Primary (SEND)')
      expect(subject.study_mode).to eq 'full_time'
      expect(subject.errors).to be_empty
    end

    context 'next_available_course_code is true' do
      let(:next_available_course_code) do
        true
      end

      it 'create the primary course' do
        valid_course_params.except('is_send', 'sites_ids', 'study_sites_ids', 'subjects_ids', 'course_code', 'study_mode').each do |key, value|
          expect(subject.public_send(key)).to eq(value)
        end

        expect(subject.is_send).to be(true)
        expect(subject.sites.map(&:id)).to eq([site.id])
        expect(subject.study_sites.map(&:id)).to eq([study_site.id])
        expect(subject.course_subjects.map { it.subject.id }).to eq([primary_subject.id])
        expect(subject.course_code).not_to be_nil
        expect(subject.course_code).not_to eq('D0CK')
        expect(subject.name).to eq('Primary (SEND)')
        expect(subject.study_mode).to eq 'full_time'
        expect(subject.errors).to be_empty
      end
    end
  end

  context 'secondary course' do
    let(:secondary_subject) { find_or_create(:secondary_subject, :biology) }

    let(:valid_course_params) do
      {
        'age_range_in_years' => '12_to_17',
        'applications_open_from' => recruitment_cycle.application_start_date,
        'funding' => 'salary',
        'is_send' => '0',
        'level' => 'secondary',
        'qualification' => 'pgce_with_qts',
        'start_date' => "September #{recruitment_cycle.year}",
        'study_mode' => ['part_time'],
        'sites_ids' => [site.id],
        'study_sites_ids' => [study_site.id],
        'subjects_ids' => [secondary_subject.id],
        'master_subject_id' => secondary_subject.id,
        'course_code' => 'D0CK'
      }
    end

    it 'create the secondary course' do
      valid_course_params.except('is_send', 'sites_ids', 'study_sites_ids', 'subjects_ids', 'course_code', 'study_mode').each do |key, value|
        expect(subject.send(key)).to eq(value)
      end

      expect(subject.is_send).to be(false)
      expect(subject.sites.map(&:id)).to eq([site.id])
      expect(subject.study_sites.map(&:id)).to eq([study_site.id])
      expect(subject.course_subjects.map { it.subject.id }).to eq([secondary_subject.id])
      expect(subject.course_code).to be_nil
      expect(subject.name).to eq('Biology')
      expect(subject.study_mode).to eq 'part_time'
      expect(subject.errors).to be_empty
    end

    context 'next_available_course_code is true' do
      let(:next_available_course_code) do
        true
      end

      it 'create the secondary course' do
        valid_course_params.except('is_send', 'sites_ids', 'study_sites_ids', 'subjects_ids', 'course_code', 'study_mode').each do |key, value|
          expect(subject.public_send(key)).to eq(value)
        end

        expect(subject.is_send).to be(false)
        expect(subject.sites.map(&:id)).to eq([site.id])
        expect(subject.study_sites.map(&:id)).to eq([study_site.id])
        expect(subject.course_subjects.map { it.subject.id }).to eq([secondary_subject.id])
        expect(subject.course_code).not_to be_nil
        expect(subject.course_code).not_to eq('D0CK')
        expect(subject.name).to eq('Biology')
        expect(subject.study_mode).to eq 'part_time'
        expect(subject.errors).to be_empty
      end
    end

    context 'study_mode param is a string' do
      let(:valid_course_params) do
        {
          'age_range_in_years' => '12_to_17',
          'applications_open_from' => recruitment_cycle.application_start_date,
          'funding' => 'salary',
          'is_send' => '0',
          'level' => 'secondary',
          'qualification' => 'pgce_with_qts',
          'start_date' => "September #{recruitment_cycle.year}",
          'study_mode' => 'part_time',
          'sites_ids' => [site.id],
          'study_sites_ids' => [study_site.id],
          'subjects_ids' => [secondary_subject.id],
          'master_subject_id' => secondary_subject.id,
          'course_code' => 'D0CK'
        }
      end

      it 'creates a course' do
        expect(subject.is_send).to be(false)
        expect(subject.sites.map(&:id)).to eq([site.id])
        expect(subject.study_sites.map(&:id)).to eq([study_site.id])
        expect(subject.course_subjects.map { it.subject.id }).to eq([secondary_subject.id])
        expect(subject.course_code).to be_nil
        expect(subject.name).to eq('Biology')
        expect(subject.study_mode).to eq 'part_time'
        expect(subject.errors).to be_empty
      end
    end
  end

  context 'further_education course' do
    let(:further_education_subject) { find_or_create(:further_education_subject) }

    let(:valid_course_params) do
      {
        'applications_open_from' => recruitment_cycle.application_start_date,
        'is_send' => '1',
        'level' => 'further_education',
        'funding' => 'fee',
        'qualification' => 'pgde',
        'start_date' => "September #{recruitment_cycle.year}",
        'study_mode' => %w[full_time part_time],
        'sites_ids' => [site.id],
        'study_sites_ids' => [study_site.id]
      }
    end

    it 'create the further_education course' do
      expect(subject.is_send).to be(true)
      expect(subject.sites.map(&:id)).to eq([site.id])
      expect(subject.study_sites.map(&:id)).to eq([study_site.id])
      expect(subject.course_subjects.map { it.subject.id }).to eq([further_education_subject.id])
      expect(subject.course_code).to be_nil
      expect(subject.name).to eq('Further education (SEND)')
      expect(subject.errors).to be_empty
      expect(subject.funding).to eq('fee')
      expect(subject.english).to eq('not_required')
      expect(subject.maths).to eq('not_required')
      expect(subject.science).to eq('not_required')
      expect(subject.study_mode).to eq 'full_time_or_part_time'
    end

    context 'next_available_course_code is true' do
      let(:next_available_course_code) do
        true
      end

      it 'create the further_education course' do
        valid_course_params.except('is_send', 'sites_ids', 'study_sites_ids', 'course_code', 'study_mode').each do |key, value|
          expect(subject.send(key)).to eq(value)
        end

        expect(subject.is_send).to be(true)
        expect(subject.sites.map(&:id)).to eq([site.id])
        expect(subject.study_sites.map(&:id)).to eq([study_site.id])
        expect(subject.course_subjects.map { it.subject.id }).to eq([further_education_subject.id])
        expect(subject.course_code).not_to be_nil
        expect(subject.course_code).not_to eq('D0CK')
        expect(subject.name).to eq('Further education (SEND)')
        expect(subject.errors).to be_empty
        expect(subject.funding).to eq('fee')
        expect(subject.english).to eq('not_required')
        expect(subject.maths).to eq('not_required')
        expect(subject.science).to eq('not_required')
        expect(subject.study_mode).to eq 'full_time_or_part_time'
      end
    end

    context 'when course sponsors visa' do
      context 'but does not require separate application deadline' do
        let(:valid_course_params) do
          { 'funding' => 'fee',
            'can_sponsor_student_visa' => 'true',
            'visa_sponsorship_application_deadline_required' => 'false',
            'visa_sponsorship_application_deadline_at(1i)' => recruitment_cycle.year,
            'visa_sponsorship_application_deadline_at(2i)' => '8',
            'visa_sponsorship_application_deadline_at(3i)' => '1' }
        end

        it 'does not save the visa sponsorship application deadline date' do
          expect(subject.visa_sponsorship_application_deadline_at).to be_nil
        end
      end

      context 'and requires a separate application deadline' do
        let(:valid_course_params) do
          { 'funding' => 'fee',
            'can_sponsor_student_visa' => 'true',
            'visa_sponsorship_application_deadline_required' => 'true',
            'visa_sponsorship_application_deadline_at(1i)' => recruitment_cycle.year,
            'visa_sponsorship_application_deadline_at(2i)' => '8',
            'visa_sponsorship_application_deadline_at(3i)' => '1' }
        end

        it 'saves the visa sponsorship application deadline at from the params' do
          deadline = DateTime.new(recruitment_cycle.year.to_i, 8, 1, 11, 59)
          expect(subject.visa_sponsorship_application_deadline_at).to eq deadline
        end
      end
    end
  end
end
