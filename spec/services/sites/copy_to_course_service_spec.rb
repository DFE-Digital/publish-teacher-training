# frozen_string_literal: true

require 'rails_helper'

describe Sites::CopyToCourseService do
  let(:course) { create(:course, provider: new_provider) }
  let(:new_provider) do
    create(:provider,
           recruitment_cycle: new_recruitment_cycle)
  end
  let(:new_recruitment_cycle) { create(:recruitment_cycle, :next) }

  before do
    described_class.call(new_site: site, new_course: course)
  end

  context 'site is a school' do
    let(:site) { create(:site, :school) }

    it 'copies the site' do
      expect(course.sites.count).to eq(1)
    end

    it 'has the same code as the original site' do
      new_site = course.sites.last
      expect(new_site.code).to eq(site.code)
    end

    describe "the new site's status" do
      subject { course.site_statuses.first }

      it { is_expected.to be_status_new_status }
    end
  end

  context 'site is a study site' do
    let(:site) { create(:site, :study_site) }

    it 'copies the study site' do
      expect(course.study_sites.count).to eq(1)
    end

    it 'has the same code as the original site' do
      new_study_site = course.study_sites.last
      expect(new_study_site.code).to eq(site.code)
    end
  end
end
