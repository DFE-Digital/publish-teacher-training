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
require "rails_helper"


RSpec.describe SiteStatus, type: :model do
  it_behaves_like "Touch course", :site_status

  RSpec::Matchers.define :have_vacancies do
    match do |actual|
      SiteStatus.with_vacancies.include?(actual)
    end
  end

  describe "auditing" do
    it { should be_audited.associated_with(:course) }
  end

  describe "associations" do
    subject { build(:site_status) }

    it { should belong_to(:site) }
    it { should belong_to(:course) }
  end

  describe "findable?" do
    describe "if discontinued on UCAS" do
      subject { create(:site_status, :discontinued) }
      it { should_not be_findable }
    end

    describe "if suspended on UCAS" do
      subject { create(:site_status, :suspended) }
      it { should_not be_findable }
    end

    describe "if new on UCAS" do
      subject { create(:site_status, :new) }
      it { should_not be_findable }
    end

    describe "if running but not published on UCAS" do
      subject { create(:site_status, :running, :unpublished) }
      it { should_not be_findable }
    end

    describe "if running and published on UCAS" do
      subject { create(:site_status, :running, :published) }
      it { should be_findable }
    end
  end

  describe "findable scope" do
    subject { SiteStatus.findable }

    context "with a course discontinued on UCAS" do
      it { should_not include(create(:site_status, :discontinued)) }
    end

    context "if suspended on UCAS" do
      it { should_not include(create(:site_status, :suspended)) }
    end

    context "if new on UCAS" do
      it { should_not include(create(:site_status, :new)) }
    end

    describe "if running but not published on UCAS" do
      it { should_not include(create(:site_status, :running, :unpublished)) }
    end

    describe "if running and published on UCAS" do
      it { should include(create(:site_status, :running, :published)) }
    end
  end

  describe "has vacancies?" do
    describe "if has part-time vacancies" do
      let(:course) { build(:course, study_mode: :part_time) }
      subject { create(:site_status, :part_time_vacancies, course: course) }
      it { should have_vacancies }
    end

    describe "if has full-time vacancies" do
      subject { create(:site_status, :full_time_vacancies) }
      it { should have_vacancies }
    end

    describe "if has both full-time and part-time vacancies" do
      let(:course) { build(:course, study_mode: :full_time_or_part_time) }
      subject { create(:site_status, :both_full_time_and_part_time_vacancies, course: course) }
      it { should have_vacancies }
    end

    describe "if has no vacancies" do
      subject { create(:site_status, :with_no_vacancies) }
      it { should_not have_vacancies }
    end
  end

  describe "vac_status" do
    specs = [
      {
        course_study_mode: :full_time,
        valid_states: %w[no_vacancies full_time_vacancies],
        invalid_states: %w[part_time_vacancies both_full_time_and_part_time_vacancies],
      },
      {
        course_study_mode: :part_time,
        valid_states: %w[no_vacancies part_time_vacancies],
        invalid_states: %w[full_time_vacancies both_full_time_and_part_time_vacancies],
      },
      {
        course_study_mode: :full_time_or_part_time,
        valid_states: %w[no_vacancies part_time_vacancies full_time_vacancies both_full_time_and_part_time_vacancies],
        invalid_states: [],
      },
    ].freeze

    specs.each do |spec|
      context "#{spec[:study_mode].to_s.humanize(capitalize: false)} course" do
        let(:course) { build(:course, study_mode: spec[:course_study_mode]) }

        spec[:valid_states].each do |state|
          context "vac_status set to #{state}" do
            subject { build(:site_status, vac_status: state, course: course) }
            it { should be_valid }
          end
        end

        spec[:invalid_states].each do |state|
          context "vac_status set to #{state}" do
            subject { build(:site_status, vac_status: state, course: course) }
            it { should_not be_valid }

            it "has a validation error about vacancy status not matching study mode" do
              subject.valid?
              expect(subject.errors.full_messages).to include("Vac status (#{state}) must be consistent with course study mode #{course.study_mode}")
            end
          end
        end
      end
    end
  end

  describe "default_vac_status_given" do
    subject { SiteStatus }
    it "should return correct default_vac_status" do
      expect(subject.default_vac_status_given(study_mode: "full_time")).to eq :full_time_vacancies
      expect(subject.default_vac_status_given(study_mode: "part_time")).to eq :part_time_vacancies
      expect(subject.default_vac_status_given(study_mode: "full_time_or_part_time")).to eq :both_full_time_and_part_time_vacancies
      expect { subject.default_vac_status_given(study_mode: "foo") }.to raise_error("Unexpected study mode foo")
    end
  end

  describe "status changes" do
    describe "when suspending a running, published site status" do
      subject { create(:site_status, :running, :published).tap(&:suspend!).reload }
      it { should be_status_suspended }
      it { should be_unpublished_on_ucas }
    end

    %i[new suspended discontinued].each do |status|
      describe "when starting a #{status}, unpublished site status" do
        subject { create(:site_status, status, :unpublished).tap(&:start!).reload }
        it { should be_status_running }
        it { should be_published_on_ucas }
      end
    end
  end
end
