# frozen_string_literal: true

require 'rails_helper'

describe '#publishable?' do
  subject { course }

  let(:course) { create(:course) }
  let(:site) { create(:site) }
  let(:study_site) { create(:site, :study_site) }
  let(:site_status) { create(:site_status, :new_status, site:) }

  # TODO: Individual scenarios should test all possible errors
  it 'adds all unpublishable error messages' do
    expect(course).not_to be_publishable
    expect(course.errors.messages).to eq(
      { sites: ['^Select at least one school'],
        accrediting_provider: ['Select an accredited provider'],
        about_course: ['^Enter information about this course'],
        how_school_placements_work: ['^Enter details about how placements work'],
        course_length: ['^Enter a course length'],
        salary_details: ['^Enter details about the salary for this course'],
        base: ['Enter GCSE requirements'] }
    )
  end

  context 'when associated accredited provider is no longer accredited' do
    let(:enrichment) { build(:course_enrichment, :subsequent_draft, created_at: 1.day.ago) }
    let(:primary_with_mathematics) { find_or_create(:primary_subject, :primary_with_mathematics) }
    let(:course) do
      create(:course, :with_gcse_equivalency, :with_accrediting_provider, :self_accredited, subjects: [primary_with_mathematics], enrichments: [enrichment], site_statuses: [site_status], study_sites: [study_site])
    end

    it 'is not publishable' do
      course.accrediting_provider.not_an_accredited_provider!
      expect(course).not_to be_publishable
    end
  end

  context 'with enrichment' do
    let(:enrichment) { build(:course_enrichment, :subsequent_draft, created_at: 1.day.ago) }
    let(:primary_with_mathematics) { find_or_create(:primary_subject, :primary_with_mathematics) }
    let(:course) do
      create(:course, :with_gcse_equivalency, :with_accrediting_provider, :self_accredited, subjects: [primary_with_mathematics], enrichments: [enrichment], site_statuses: [site_status], study_sites: [study_site])
    end

    its(:publishable?) { is_expected.to be_truthy }
  end

  context 'with no enrichment' do
    let(:course) do
      create(:course, site_statuses: [site_status])
    end

    its(:publishable?) { is_expected.to be_falsey }

    describe 'course errors' do
      subject do
        course.publishable?
        course.errors
      end

      it { is_expected.not_to be_empty }
    end
  end

  context 'with no sites' do
    let(:enrichment) { build(:course_enrichment, :subsequent_draft, created_at: 1.day.ago) }
    let(:course) do
      create(:course, site_statuses: [], enrichments: [enrichment])
    end

    its(:publishable?) { is_expected.to be_falsey }

    describe 'course errors' do
      subject do
        course.publishable?
        course.errors
      end

      it { is_expected.not_to be_empty }
    end
  end

  context 'when publishing a NON teacher degree apprenticeship course without A levels' do
    it 'does not require A level to be answered' do
      course = create(
        :course,
        a_level_subject_requirements: nil
      )
      course.valid?(:publish)
      expect(course.errors[:a_level_subject_requirements]).to eq([])
    end
  end

  context 'when publishing a teacher degree apprenticeship course without A levels subject requirements' do
    it 'requires to add A level subject requirement' do
      course = create(
        :course,
        :with_teacher_degree_apprenticeship,
        :resulting_in_undergraduate_degree_with_qts,
        a_level_subject_requirements: []
      )
      course.valid?(:publish)
      expect(course.errors[:a_level_subject_requirements]).to include('Enter A level requirements')
    end
  end

  context 'when publishing a teacher degree apprenticeship course with A levels without pending A level answered' do
    it 'requires to add if accept pending A level' do
      course = create(
        :course,
        :with_teacher_degree_apprenticeship,
        :resulting_in_undergraduate_degree_with_qts,
        :with_a_level_requirements,
        accept_pending_a_level: nil
      )
      course.valid?(:publish)
      expect(course.errors[:accept_pending_a_level]).to include('Enter information on pending A levels')
    end
  end

  context 'when publishing a teacher degree apprenticeship course with A levels without A level equivalency answered' do
    it 'requires to add A level equivalency requirement' do
      course = create(
        :course,
        :with_teacher_degree_apprenticeship,
        :resulting_in_undergraduate_degree_with_qts,
        :with_a_level_requirements,
        accept_a_level_equivalency: nil
      )
      course.valid?(:publish)
      expect(course.errors[:accept_a_level_equivalency]).to include('Enter A level equivalency test requirements')
    end
  end
end
