# frozen_string_literal: true

require 'rails_helper'

describe Course do
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
          accrediting_provider: ['Select an accrediting provider'],
          about_course: ['^Enter details about this course'],
          how_school_placements_work: ['^Enter details about school placements'],
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
  end
end
