# == Schema Information
#
# Table name: course
#
#  id                      :integer          not null, primary key
#  age_range               :text
#  course_code             :text
#  name                    :text
#  profpost_flag           :text
#  program_type            :text
#  qualification           :integer          not null
#  start_date              :datetime
#  study_mode              :text
#  accrediting_provider_id :integer
#  provider_id             :integer          default(0), not null
#  modular                 :text
#  english                 :integer
#  maths                   :integer
#  science                 :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require 'rails_helper'

RSpec.describe Course, type: :model do
  let(:subject) { create(:course) }

  describe 'associations' do
    it { should belong_to(:provider) }
    it { should belong_to(:accrediting_provider).optional }
    it { should have_and_belong_to_many(:subjects) }
    it { should have_many(:site_statuses) }
    it { should have_many(:sites) }
  end

  describe 'no site statuses' do
    its(:site_statuses) { should be_empty }
    its(:findable?) { should be false }
    its(:open_for_applications?) { should be false }
    its(:has_vacancies?) { should be false }
  end

  context 'with site statuses' do
    describe 'findable?' do
      context 'with at least one site status as findable' do
        context 'single site status as findable' do
          let(:subject) { create(:course, site_statuses: course_site_statuses) }

          let(:course_site_statuses) { [create(:site_status, :findable)] }

          its(:site_statuses) { should_not be_empty }
          its(:findable?) { should be true }
        end

        context 'single site status as findable and mix site status as non findable' do
          let(:subject) { create(:course, site_statuses: course_site_statuses) }

          let(:course_site_statuses) {
            [create(:site_status, :findable),
             create(:site_status, :with_any_vacancy),
             create(:site_status),
             create(:site_status, :applications_being_accepted_now),
             create(:site_status, :applications_being_accepted_in_future)]
          }

          its(:site_statuses) { should_not be_empty }
          its(:findable?) { should be true }
        end
      end
    end

    describe 'has_vacancies' do
      context 'with at least one site status has vacancies' do
        context 'single site status has vacancies' do
          let(:subject) { create(:course, site_statuses: course_site_statuses) }

          let(:course_site_statuses) { [create(:site_status, :with_any_vacancy)] }

          its(:site_statuses) { should_not be_empty }
          its(:has_vacancies?) { should be true }
        end

        context 'single site status has vacancies and mix site status with no vacancies' do
          let(:subject) { create(:course, site_statuses: course_site_statuses) }

          let(:course_site_statuses) {
            [create(:site_status, :findable),
             create(:site_status, :with_any_vacancy),
             create(:site_status),
             create(:site_status, :applications_being_accepted_now),
             create(:site_status, :applications_being_accepted_in_future)]
          }

          its(:site_statuses) { should_not be_empty }
          its(:has_vacancies?) { should be true }
        end
      end
    end
    describe 'open_for_applications?' do
      context 'with at least one site status applications_being_accepted_now' do
        context 'single site status applications_being_accepted_now as it open now' do
          let(:subject) { create(:course, site_statuses: course_site_statuses) }

          let(:course_site_statuses) {
            [create(:site_status, :findable, :applications_being_accepted_now, :with_any_vacancy)]
          }

          its(:site_statuses) { should_not be_empty }
          its(:open_for_applications?) { should be true }
        end
        context 'single site status applications_being_accepted_now as it open future' do
          let(:subject) { create(:course, site_statuses: course_site_statuses) }

          let(:course_site_statuses) {
            [create(:site_status, :applications_being_accepted_in_future)]
          }

          its(:site_statuses) { should_not be_empty }
          its(:open_for_applications?) { should be false }
        end
        context 'site statuses applications_being_accepted_now as it open now & future' do
          let(:subject) { create(:course, site_statuses: course_site_statuses) }

          let(:course_site_statuses) {
            [create(:site_status, :findable, :applications_being_accepted_now, :with_any_vacancy),
             create(:site_status, :findable, :applications_being_accepted_in_future, :with_any_vacancy)]
          }

          its(:site_statuses) { should_not be_empty }
          its(:open_for_applications?) { should be true }
        end
        context 'site statuses applications_being_accepted_now as it open now & future and mix site status as non findable' do
          let(:subject) { create(:course, site_statuses: course_site_statuses) }

          let(:course_site_statuses) {
            [create(:site_status, :findable),
             create(:site_status, :with_any_vacancy),
             create(:site_status),
             create(:site_status, :applications_being_accepted_now),
             create(:site_status, :applications_being_accepted_in_future)]
          }

          its(:site_statuses) { should_not be_empty }
          its(:findable?) { should be true }
          its(:open_for_applications?) { should be false }
        end
      end
    end

    its(:site_statuses) { should be_empty }
    its(:findable?) { should be false }
    its(:open_for_applications?) { should be false }
    its(:has_vacancies?) { should be false }
  end

  describe '#changed_since' do
    context 'with no parameters' do
      let!(:old_course) { create(:course, age: 1.hour.ago) }
      let!(:course) { create(:course, age: 1.hour.ago) }

      subject { Course.changed_since(nil) }

      it { should include course }
      it { should include old_course }
    end

    context 'with a course that was just updated' do
      let(:course) { create(:course, age: 1.hour.ago) }
      let!(:old_course) { create(:course, age: 1.hour.ago) }

      before { course.touch }

      subject { Course.changed_since(10.minutes.ago) }

      it { should include course }
      it { should_not include old_course }
    end

    context 'with a course that has been changed less than a second after the given timestamp' do
      let(:timestamp) { 5.minutes.ago }
      let(:course) { create(:course, updated_at: timestamp + 0.001.seconds) }

      subject { Course.changed_since(timestamp) }

      it { should include course }
    end

    context 'with a course that has been changed exactly at the given timestamp' do
      let(:timestamp) { 10.minutes.ago }
      let(:course) { create(:course, updated_at: timestamp) }

      subject { Course.changed_since(timestamp) }

      it { should_not include course }
    end
  end

  describe 'qualifications' do
    context "course with qts qualication" do
      let(:subject) { create(:course, :resulting_in_qts) }

      its(:qualifications) { should eq %i[qts] }
    end

    context "course with pgce qts qualication" do
      let(:subject) { create(:course, :resulting_in_pgce_with_qts) }

      its(:qualifications) { should eq %i[qts pgce] }
    end

    context "course with pgde qts qualication" do
      let(:subject) { create(:course, :resulting_in_pgde_with_qts) }

      its(:qualifications) { should eq %i[qts pgde] }
    end

    context "course with pgce qualication" do
      let(:subject) { create(:course, :resulting_in_pgce) }

      its(:qualifications) { should eq %i[pgce] }
    end

    context "course with pgde qualication" do
      let(:subject) { create(:course, :resulting_in_pgde) }

      its(:qualifications) { should eq %i[pgde] }
    end
  end
end
