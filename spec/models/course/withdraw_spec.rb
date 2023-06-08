# frozen_string_literal: true

require 'rails_helper'

describe Course do
  describe 'withdraw' do
    let(:course) { create(:course, provider:, site_statuses: [site_status1, site_status2, site_status3], enrichments: [enrichment]) }
    let(:provider) { build(:provider) }
    let(:enrichment) { build(:course_enrichment) }
    let(:site_status1) { build(:site_status, :running, :published, :full_time_vacancies, site:) }
    let(:site_status2) { build(:site_status, :new_status, :full_time_vacancies, site:) }
    let(:site_status3) { build(:site_status, :suspended, :no_vacancies, site:) }
    let(:site) { build(:site, provider:) }

    before do
      course.withdraw
    end

    context 'a published course' do
      let(:enrichment) { build(:course_enrichment, :published) }

      it 'is not findable' do
        expect(course.findable?).to be(false)
      end

      it 'is not published' do
        expect(course.is_published?).to be(false)
      end

      it 'has a content_status of withdrawn' do
        expect(course.content_status).to eq(:withdrawn)
      end
    end

    context 'an unpublished course' do
      it 'adds an error to the course' do
        expect(course.reload.errors[:withdraw].first).to eq('Courses that have not been published should be deleted not withdrawn')
      end
    end
  end
end
