# == Schema Information
#
# Table name: course_site
#
#  id                         :integer          not null, primary key
#  applications_accepted_from :date
#  course_id                  :integer
#  publish                    :text
#  site_id                    :integer
#  status                     :text
#  vac_status                 :text
#
require 'rails_helper'


RSpec.describe SiteStatus, type: :model do
  describe 'associations' do
    it { should belong_to(:site) }
    it { should belong_to(:course) }
  end

  describe 'findable?' do
    describe 'running and published returns true' do
      let(:site_status) { create(:site_status, :findable) }
      it { expect(site_status.findable?).to eq(true) }
      it { expect(site_status.status_before_type_cast).to eq('R') }
      it { expect(site_status.publish).to eq('Y') }
    end
  end

  context "has_vacancies?" do
    describe 'full time vacancy returns true' do
      let(:site_status) { create(:site_status, :full_time_vacancies) }
      it { expect(site_status.has_vacancies?).to eq(true) }
    end

    describe 'part time vacancy returns true' do
      let(:site_status) { create(:site_status, :full_time_vacancies) }
      it { expect(site_status.has_vacancies?).to eq(true) }
    end

    describe 'full time and part time vacancies returns true' do
      let(:site_status) { create(:site_status, :both_full_time_and_part_time_vacancies) }

      it { expect(site_status.has_vacancies?).to eq(true) }
    end

    describe 'no vacancies returns false' do
      let(:site_status) { create(:site_status) }

      it { expect(site_status.has_vacancies?).to eq(false) }
    end
  end

  context 'applications_being_accepted_now?' do
    context 'should return true' do
      describe 'has past applications_accepted_from date and has has_vacancies and is findable' do
        let(:site_status) { create(:site_status, :findable_and_with_any_vacancy, :applications_being_accepted_now) }
        it { expect(site_status.applications_being_accepted_now?).to eq(true) }
        it { expect(site_status.has_vacancies?).to eq(true) }
        it { expect(site_status.findable?).to eq(true) }
        it { expect(site_status.applications_accepted_from).to be <= 0.days.ago }
      end

      describe 'has past applications_accepted_from date and has no has_vacancies and is findable' do
        let(:site_status) { create(:site_status, :findable, :applications_being_accepted_now) }
        it { expect(site_status.applications_being_accepted_now?).to eq(true) }
        it { expect(site_status.has_vacancies?).to eq(false) }
        it { expect(site_status.findable?).to eq(true) }
        it { expect(site_status.applications_accepted_from).to be <= 0.days.ago }
      end

      describe 'has past applications_accepted_from date and has no has_vacancies and is not findable' do
        let(:site_status) { create(:site_status, :applications_being_accepted_now) }
        it { expect(site_status.applications_being_accepted_now?).to eq(true) }
        it { expect(site_status.has_vacancies?).to eq(false) }
        it { expect(site_status.findable?).to eq(false) }
        it { expect(site_status.applications_accepted_from).to be <= 0.days.ago }
      end
    end

    context 'should return false' do
      describe 'has future applications_accepted_from date and has has_vacancies and is findable' do
        let(:site_status) { create(:site_status, :findable_and_with_any_vacancy, :applications_being_accepted_in_future) }
        it { expect(site_status.applications_being_accepted_now?).to eq(false) }

        it { expect(site_status.has_vacancies?).to eq(true) }
        it { expect(site_status.findable?).to eq(true) }
        it { expect(site_status.applications_accepted_from).to be >= 0.days.ago }
      end

      describe 'has future applications_accepted_from date and has no has_vacancies and is findable' do
        let(:site_status) { create(:site_status, :findable, :applications_being_accepted_in_future) }
        it { expect(site_status.applications_being_accepted_now?).to eq(false) }

        it { expect(site_status.has_vacancies?).to eq(false) }
        it { expect(site_status.findable?).to eq(true) }
        it { expect(site_status.applications_accepted_from).to be >= 0.days.ago }
      end

      describe 'has future applications_accepted_from date and has no has_vacancies and is not findable' do
        let(:site_status) { create(:site_status, :applications_being_accepted_in_future) }
        it { expect(site_status.applications_being_accepted_now?).to eq(false) }

        it { expect(site_status.has_vacancies?).to eq(false) }
        it { expect(site_status.findable?).to eq(false) }
        it { expect(site_status.applications_accepted_from).to be >= 0.days.ago }
      end

      describe 'has no applications_accepted_from date and has has_vacancies and is findable' do
        let(:site_status) { create(:site_status, :with_any_vacancy, :findable) }
        it { expect(site_status.applications_being_accepted_now?).to eq(false) }

        it { expect(site_status.has_vacancies?).to eq(true) }
        it { expect(site_status.findable?).to eq(true) }
        it { expect(site_status.applications_accepted_from).to eq(nil) }
      end

      describe 'has no applications_accepted_from date and has has_vacancies and is not findable' do
        let(:site_status) { create(:site_status, :with_any_vacancy) }
        it { expect(site_status.applications_being_accepted_now?).to eq(false) }

        it { expect(site_status.has_vacancies?).to eq(true) }
        it { expect(site_status.findable?).to eq(false) }
        it { expect(site_status.applications_accepted_from).to eq(nil) }
      end

      describe 'has no applications_accepted_from date and has no has_vacancies and is not findable' do
        let(:site_status) { create(:site_status) }
        it { expect(site_status.applications_being_accepted_now?).to eq(false) }

        it { expect(site_status.has_vacancies?).to eq(false) }
        it { expect(site_status.findable?).to eq(false) }
        it { expect(site_status.applications_accepted_from).to eq(nil) }
      end
    end
  end
end
