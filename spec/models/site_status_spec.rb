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
  RSpec::Matchers.define :be_findable do
    match do |actual|
      SiteStatus.findable.include?(actual)
    end
  end

  RSpec::Matchers.define :be_open_for_applications do
    match do |actual|
      SiteStatus.open_for_applications.include?(actual)
    end
  end

  RSpec::Matchers.define :have_vacancies do
    match do |actual|
      SiteStatus.with_vacancies.include?(actual)
    end
  end

  describe 'associations' do
    it { should belong_to(:site) }
    it { should belong_to(:course) }
  end

  describe 'is it on find?' do
    describe 'if discontinued on UCAS' do
      subject { create(:site_status, :discontinued) }
      it { should_not be_findable }
    end

    describe 'if suspended on UCAS' do
      subject { create(:site_status, :suspended) }
      it { should_not be_findable }
    end

    describe 'if new on UCAS' do
      subject { create(:site_status, :new) }
      it { should_not be_findable }
    end

    describe 'if running but not published on UCAS' do
      subject { create(:site_status, :running, :unpublished) }
      it { should_not be_findable }
    end

    describe 'if running and published on UCAS' do
      subject { create(:site_status, :running, :published) }
      it { should be_findable }
    end
  end

  describe 'applications open?' do
    describe 'if on find, application date open and has full-time vacancies' do
      subject { create(:site_status, :findable, :applications_being_accepted_now, :full_time_vacancies) }
      it { should be_open_for_applications }
    end

    describe 'if on find, application date open and has part-time vacancies' do
      subject { create(:site_status, :with_course_study_mode_as_part_time, :findable, :applications_being_accepted_now, :part_time_vacancies) }
      it { should be_open_for_applications }
    end

    describe 'if on find, application date open and has both full-time and part-time vacancies' do
      subject { create(:site_status, :with_course_study_mode_as_full_time_or_part_time, :findable, :applications_being_accepted_now, :both_full_time_and_part_time_vacancies) }
      it { should be_open_for_applications }
    end

    describe 'if not on find' do
      subject { create(:site_status, :suspended) }
      it { should_not be_open_for_applications }
    end

    describe 'if on find but applications accepted in the future' do
      subject { create(:site_status, :findable, :applications_being_accepted_in_future) }
      it { should_not be_open_for_applications }
    end

    describe 'if on find, applications accepted now but no vacancies' do
      subject { create(:site_status, :findable, :applications_being_accepted_now, :with_no_vacancies) }
      it { should_not be_open_for_applications }
    end
  end

  describe "has vacancies?" do
    describe 'if has part-time vacancies' do
      subject { create(:site_status, :with_course_study_mode_as_part_time, :part_time_vacancies) }
      it { should have_vacancies }
    end

    describe 'if has full-time vacancies' do
      subject { create(:site_status, :full_time_vacancies) }
      it { should have_vacancies }
    end

    describe 'if has both full-time and part-time vacancies' do
      subject { create(:site_status, :with_course_study_mode_as_full_time_or_part_time, :both_full_time_and_part_time_vacancies) }
      it { should have_vacancies }
    end

    describe 'if has no vacancies' do
      subject { create(:site_status, :with_no_vacancies) }
      it { should_not have_vacancies }
    end
  end

  describe "#update" do
    all_vac_statuses = %w[no_vacancies part_time_vacancies full_time_vacancies both_full_time_and_part_time_vacancies]
    specs = [
      {
        study_mode: :with_course_study_mode_as_nil,
        valid_states: %w[no_vacancies]
      },
      {
        study_mode: :with_course_study_mode_as_full_time,
        valid_states: %w[no_vacancies full_time_vacancies]
      },
      {
        study_mode: :with_course_study_mode_as_part_time,
        valid_states: %w[no_vacancies part_time_vacancies]
      },
      {
        study_mode: :with_course_study_mode_as_full_time_or_part_time,
        valid_states: all_vac_statuses
      },
    ].freeze

    specs.each do |spec|
      context "site status #{spec[:study_mode].to_s.humanize(capitalize: false)}" do
        subject { create(:site_status, spec[:study_mode], :with_no_vacancies) }

        spec[:valid_states].each do |state|
          context "set a valid vac_status to #{state}" do
            let!(:has_saved) {
              subject.update(vac_status: state)
            }

            it "updated successfully" do
              expect(subject.vac_status).to eq state.to_s
              expect(has_saved).to eq true
            end
          end
        end

        invalid_states = (spec[:valid_states] + all_vac_statuses) - (spec[:valid_states] & all_vac_statuses)

        invalid_states.each do |state|
          context "set an invalid the vac_status to #{state}" do
            let!(:has_saved) {
              subject.update(vac_status: state)
            }

            it "updated unsuccessfully" do
              expect(subject.vac_status).to eq state.to_s
              expect(has_saved).to eq false
            end
          end
        end
      end
    end
  end
end
