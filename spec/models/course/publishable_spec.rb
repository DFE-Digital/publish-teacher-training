# frozen_string_literal: true

require 'rails_helper'

describe Course do
  describe '#publishable?' do
    subject { course }

    let(:course) { create(:course) }
    let(:site) { create(:site) }
    let(:site_status) { create(:site_status, :new_status, site:) }

    its(:publishable?) { is_expected.to be_falsey }

    context 'with enrichment' do
      let(:enrichment) { build(:course_enrichment, :subsequent_draft, created_at: 1.day.ago) }
      let(:primary_with_mathematics) { find_or_create(:primary_subject, :primary_with_mathematics) }
      let(:course) do
        create(:course, :with_gcse_equivalency, :self_accredited, subjects: [primary_with_mathematics], enrichments: [enrichment], site_statuses: [site_status])
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
