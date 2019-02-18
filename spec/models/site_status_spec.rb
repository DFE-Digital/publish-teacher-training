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
      let(:subject) { create(:site_status, :findable) }

      its(:findable?) { should be true }
      its(:status_before_type_cast) { should eq('R') }
      its(:publish) { should eq('Y') }
    end
  end

  context "has_vacancies?" do
    describe 'full time vacancy returns true' do
      let(:subject) { create(:site_status, :full_time_vacancies) }

      its(:has_vacancies?) { should be true }
    end

    describe 'part time vacancy returns true' do
      let(:subject) { create(:site_status, :full_time_vacancies) }
      its(:has_vacancies?) { should be true }
    end

    describe 'full time and part time vacancies returns true' do
      let(:subject) { create(:site_status, :both_full_time_and_part_time_vacancies) }

      its(:has_vacancies?) { should be true }
    end

    describe 'no vacancies returns false' do
      let(:subject) { create(:site_status) }

      its(:has_vacancies?) { should be false }
    end
  end

  context 'applications_being_accepted_now?' do
    context 'should return true' do
      describe 'has past applications_accepted_from date and has has_vacancies and is findable' do
        let(:subject) { create(:site_status, :findable_and_with_any_vacancy, :applications_being_accepted_now) }

        its(:applications_being_accepted_now?) { should be true }
        its(:has_vacancies?) { should be true }
        its(:findable?) { should be true }
        its(:applications_accepted_from) { should be <= 0.days.ago }
      end

      describe 'has past applications_accepted_from date and has no has_vacancies and is findable' do
        let(:subject) { create(:site_status, :findable, :applications_being_accepted_now) }

        its(:applications_being_accepted_now?) { should be true }
        its(:has_vacancies?) { should be false }
        its(:findable?) { should be true }
        its(:applications_accepted_from) { should be <= 0.days.ago }
      end

      describe 'has past applications_accepted_from date and has no has_vacancies and is not findable' do
        let(:subject) { create(:site_status, :applications_being_accepted_now) }

        its(:applications_being_accepted_now?) { should be true }
        its(:has_vacancies?) { should be false }
        its(:findable?) { should be false }
        its(:applications_accepted_from) { should be <= 0.days.ago }
      end
    end

    context 'should return false' do
      describe 'has future applications_accepted_from date and has has_vacancies and is findable' do
        let(:subject) { create(:site_status, :findable_and_with_any_vacancy, :applications_being_accepted_in_future) }

        its(:applications_being_accepted_now?) { should be false }
        its(:has_vacancies?) { should be true }
        its(:findable?) { should be true }
        its(:applications_accepted_from) { should be >= 0.days.ago }
      end

      describe 'has future applications_accepted_from date and has no has_vacancies and is findable' do
        let(:subject) { create(:site_status, :findable, :applications_being_accepted_in_future) }

        its(:applications_being_accepted_now?) { should be false }
        its(:has_vacancies?) { should be false }
        its(:findable?) { should be true }
        its(:applications_accepted_from) { should be >= 0.days.ago }
      end

      describe 'has future applications_accepted_from date and has no has_vacancies and is not findable' do
        let(:subject) { create(:site_status, :applications_being_accepted_in_future) }

        its(:applications_being_accepted_now?) { should be false }
        its(:has_vacancies?) { should be false }
        its(:findable?) { should be false }
        its(:applications_accepted_from) { should be >= 0.days.ago }
      end

      describe 'has no applications_accepted_from date and has has_vacancies and is findable' do
        let(:subject) { create(:site_status, :with_any_vacancy, :findable) }

        its(:applications_being_accepted_now?) { should be false }
        its(:has_vacancies?) { should be true }
        its(:findable?) { should be true }
        its(:applications_accepted_from) { should be nil }
      end

      describe 'has no applications_accepted_from date and has has_vacancies and is not findable' do
        let(:subject) { create(:site_status, :with_any_vacancy) }

        its(:applications_being_accepted_now?) { should be false }
        its(:has_vacancies?) { should be true }
        its(:findable?) { should be false }
        its(:applications_accepted_from) { should be nil }
      end

      describe 'has no applications_accepted_from date and has no has_vacancies and is not findable' do
        let(:subject) { create(:site_status) }

        its(:applications_being_accepted_now?) { should be false }
        its(:has_vacancies?) { should be false }
        its(:findable?) { should be false }
        its(:applications_accepted_from) { should be nil }
      end
    end
  end
end
