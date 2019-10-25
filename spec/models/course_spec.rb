# == Schema Information
#
# Table name: course
#
#  id                        :integer          not null, primary key
#  age_range                 :text
#  course_code               :text
#  name                      :text
#  profpost_flag             :text
#  program_type              :text
#  qualification             :integer          not null
#  start_date                :datetime
#  study_mode                :text
#  accrediting_provider_id   :integer
#  provider_id               :integer          default(0), not null
#  modular                   :text
#  english                   :integer
#  maths                     :integer
#  science                   :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  changed_at                :datetime         not null
#  accrediting_provider_code :text
#  discarded_at              :datetime
#  age_range_in_years        :string
#  applications_open_from    :date
#  is_send                   :boolean          default(FALSE)
#  level                     :string
#

require "rails_helper"

describe Course, type: :model do
  let(:recruitment_cycle) { course.recruitment_cycle }
  let(:course) { create(:course, name: "Biology", course_code: "3X9F") }
  let(:subject) { course }
  let(:french) { find_or_create(:modern_languages_subject, :french) }
  let!(:financial_incentive) { create(:financial_incentive, subject: modern_languages) }
  let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }

  its(:to_s) { should eq("Biology (#{course.provider.provider_code}/3X9F) [#{course.recruitment_cycle}]") }
  its(:modular) { should eq("") }

  describe "auditing" do
    it { should be_audited }
    it { should have_associated_audits }
  end

  describe "associations" do
    it { should belong_to(:provider) }
    it {
      should belong_to(:accrediting_provider)
                  .with_foreign_key(:accrediting_provider_code)
                  .with_primary_key(:provider_code)
                  .optional
    }
    it { should have_many(:subjects).through(:course_subjects) }
    it { should have_many(:site_statuses) }
    it { should have_many(:sites) }
    it { should have_many(:enrichments) }
    it { should have_many(:financial_incentives) }
  end

  describe "#ensure_modern_languages" do
    it "adds modern languages if a languages subject is selected" do
      course = build(:course, level: "secondary", subjects: [french])
      course.ensure_modern_languages
      expect(course.subjects).to match_array([modern_languages, french])
      expect(course).to be_valid
    end

    it "does not duplicate add modern language if it has already been added" do
      course = build(:course, level: "secondary", subjects: [modern_languages, french])
      course.ensure_modern_languages
      expect(course.subjects).to match_array([modern_languages, french])
      expect(course).to be_valid
    end
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:profpost_flag) }
    it { should validate_presence_of(:program_type) }
    it { should validate_presence_of(:qualification) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:study_mode) }


    it { should validate_presence_of(:sites).on(:publish) }
    it { should validate_presence_of(:subjects).on(:publish) }
    it { should validate_presence_of(:enrichments).on(:publish) }

    it { should validate_presence_of(:level).on(:create) }
    it {
      should validate_presence_of(:level)
        .on(:publish)
        .with_message("^There is a problem with this course. Contact support to fix it (Error: L)")
    }

    it "validates scoped to provider_id and only on create and update" do
      expect(create(:course)).to validate_uniqueness_of(:course_code)
                                  .scoped_to(:provider_id)
                                  .on(%i[create update])
    end

    describe "valid?" do
      context "blank attribute" do
        let(:course) { build(:course, **blank_field) }

        subject do
          course.valid?
          course.errors.full_messages.first
        end

        context "age_range_in_years" do
          let(:blank_field) { { age_range_in_years: nil } }

          it { should include "Age range in years can't be blank" }
        end

        context "maths" do
          let(:blank_field) { { maths: nil } }

          it { should include "Pick an option for Maths" }
        end

        context "english" do
          let(:blank_field) { { english: nil } }

          it { should include "Pick an option for English" }
        end

        context "science" do
          let(:blank_field) { { science: nil } }

          it { should include "Pick an option for Science" }
        end
      end

      context "invalid_enrichment" do
        let(:course) { create(:course, enrichments: [invalid_enrichment]) }
        let(:invalid_enrichment) { build(:course_enrichment, about_course: "") }

        before do
          subject
          invalid_enrichment.about_course = Faker::Lorem.sentence(word_count: 1000)
          subject.valid?
        end

        it "should add enrichment errors" do
          expect(subject.errors.full_messages).to_not be_empty
        end
      end
    end

    describe "publishable?" do
      context "invalid enrichment" do
        let(:course) { create(:course, enrichments: [invalid_enrichment]) }
        let(:invalid_enrichment) { create(:course_enrichment, about_course: "") }

        before do
          subject.publishable?
        end

        it "should add enrichment errors" do
          expect(subject.errors.full_messages).to_not be_empty
        end
      end

      context "invalid subjects" do
        let(:initial_draft_enrichment) { build(:course_enrichment, :published) }
        let(:course) { create(:course, level: :secondary, site_statuses: [create(:site_status, :new)], enrichments: [initial_draft_enrichment]) }

        before do
          subject.publishable?
        end

        it "should add subjects" do
          expect(subject.errors.full_messages).to match_array(["There is a problem with this course. Contact support to fix it (Error: S)"])
        end
      end
    end

    context "if subjects are empty" do
      let(:course) { create(:course) }

      it "passes validation" do
        expect(course.valid?).to be_truthy
      end
    end

    context "course has been assigned secondary level" do
      let(:course) { create(:course, level: "secondary", subjects: [find_or_create(:secondary_subject, :english)]) }

      context "modern foreign languages" do
        it "validates even with multiple languages" do
          course.subjects = [modern_languages, find_or_create(:modern_languages_subject, :japanese), find_or_create(:modern_languages_subject, :french)]
          expect(course.valid?).to be_truthy
        end
      end

      it "validates if the subject is of that level" do
        course.subjects = [find_or_create(:secondary_subject, :mathematics)]
        expect(course.valid?).to be_truthy
      end

      it "does not validate if the subject is not of that level" do
        course.subjects = [find_or_create(:primary_subject, :primary_with_mathematics)]
        expect(course.valid?).to be_falsey
        expect(course.errors[:subjects]).to eq(["must be secondary"])
      end

      it "validates if there are only 2 subjects" do
        course.subjects = [find_or_create(:secondary_subject, :mathematics), find_or_create(:secondary_subject, :english)]
        expect(course.valid?).to be_truthy
        expect(course.errors[:subjects]).to eq([])
      end

      it "does not validate if there are more than 2 subjects" do
        course.subjects = [find_or_create(:secondary_subject, :mathematics), find_or_create(:secondary_subject, :english), find_or_create(:secondary_subject, :history)]
        expect(course.valid?).to be_falsey
        expect(course.errors[:subjects]).to eq(["has too many subjects"])
      end
    end

    context "course has been assigned primary level" do
      let(:course) { create(:course, level: :primary, subjects: [find_or_create(:primary_subject, :primary_with_english)]) }

      it "validates if the subject is of that level" do
        course.subjects = [find_or_create(:primary_subject, :primary_with_mathematics)]
        expect(course.valid?).to be_truthy
      end

      it "does not validate if the subject is not of that level" do
        course.subjects = [find_or_create(:secondary_subject, :mathematics)]
        expect(course.valid?).to be_falsey
        expect(course.errors[:subjects]).to eq(["must be primary"])
      end

      it "does not validate if there is more than one subject" do
        course.subjects = [find_or_create(:primary_subject, :primary_with_mathematics), find_or_create(:primary_subject, :primary_with_english)]
        expect(course.valid?).to be_falsey
        expect(course.errors[:subjects]).to eq(["has too many subjects"])
      end
    end

    context "course has been assigned further education level" do
      let(:course) { create(:course, :infer_level, qualification: "pgce", subjects: [find_or_create(:further_education_subject)]) }

      it "validates if the subject is of that level" do
        course.subjects = [find_or_create(:further_education_subject)]
        expect(course.valid?).to be_truthy
      end

      it "does not validate if the subject is not of that level" do
        course.subjects = [find_or_create(:secondary_subject, :biology)]
        expect(course.valid?).to be_falsey
        expect(course.errors[:subjects]).to eq(["must be further education"])
      end

      it "does not validate if there is more than one subject" do
        course.subjects = [find_or_create(:further_education_subject), find_or_create(:primary_subject)]
        expect(course.valid?).to be_falsey
        expect(course.errors[:subjects]).to eq(["has too many subjects"])
      end
    end
  end

  describe "changed_at" do
    it "is set on create" do
      course = create(:course)
      expect(course.changed_at).to be_present
      expect(course.changed_at).to eq course.updated_at
    end

    it "is set on update" do
      Timecop.freeze do
        course = create(:course, changed_at: 1.hour.ago)
        course.touch
        expect(course.changed_at).to eq course.updated_at
        expect(course.changed_at).to eq Time.now.utc
      end
    end
  end

  its(:recruitment_cycle) { should eq find(:recruitment_cycle) }

  describe "no site statuses" do
    its(:site_statuses) { should be_empty }
    its(:findable?) { should be false }
    its(:open_for_applications?) { should be false }
    its(:has_vacancies?) { should be false }
  end

  context "with sites" do
    let(:first_site) { create(:site) }
    let(:first_site_status) { create(:site_status, :running, site: first_site) }
    let(:second_site) { create(:site) }
    let(:second_site_status) { create(:site_status, :suspended, site: second_site) }
    let(:new_site) { create(:site) }

    subject { create(:course, site_statuses: [first_site_status, second_site_status]) }

    describe "#sites" do
      it "should only return new and running sites" do
        expect(subject.sites.to_a).to eq([first_site])
      end
    end

    describe "sites=" do
      before do
        subject.sites = [second_site, new_site]
      end

      context "with a ucas_status of new" do
        let(:new_site_status) { create(:site_status, :new, site: site_with_new_site_status) }
        let(:site_with_new_site_status) { create(:site) }
        let(:subject) { create(:course, site_statuses: [new_site_status]) }

        it "does not set the site to running" do
          expect(second_site_status.reload.status).to eq("suspended")
        end

        it "should destroy the old site status" do
          expect(SiteStatus.where(id: new_site_status.id)).to be_empty
        end
      end

      context "With an unpersisted course" do
        let(:course) { build(:course) }

        before { course.sites = [first_site, second_site] }

        it "sets the sites" do
          expect(course.sites).to eq([first_site, second_site])
        end

        it "does not persist the course" do
          expect(course).not_to be_persisted
        end

        xcontext "Which is then saved" do
          it "Should only have two site statuses" do
            course.save
            expect(course.site_statuses.count).to eq(2)
          end
        end
      end

      it "should assign new sites" do
        expect(subject.sites.to_a).to eq([second_site, new_site])
      end

      it "should set the sites to running" do
        expect(second_site_status.reload.status).to eq("running")
      end

      it "should set old site_status to suspended" do
        expect(first_site_status.reload.status).to eq("suspended")
      end
    end
  end

  context "with site statuses" do
    let(:new_site_status) { build(:site_status, :new) }
    let(:new_site_status2) { build(:site_status, :new) }
    let(:findable) { build(:site_status, :findable) }
    let(:suspended) { build(:site_status, :suspended) }
    let(:with_any_vacancy) { build(:site_status, :with_any_vacancy) }
    let(:default) { build(:site_status) }
    let(:site_status_with_no_vacancies) { build(:site_status, :with_no_vacancies) }

    describe "#findable_site_statuses" do
      context "with a site_statuses association that have been loaded" do
        let(:course) { create(:course, site_statuses: []) }

        it "uses #select on the association" do
          allow(course.site_statuses).to receive(:select).and_return([])

          course.findable_site_statuses

          expect(course.site_statuses).to have_received(:select)
        end

        context "with a findable site" do
          subject { create(:course, site_statuses: [findable]) }

          its(:findable_site_statuses) { should_not be_empty }
        end

        context "with no findable sites" do
          subject { create(:course, site_statuses: [suspended]) }

          its(:findable_site_statuses) { should be_empty }
        end

        context "with at least one findable sites" do
          subject { create(:course, site_statuses: [findable, suspended]) }

          its(:findable_site_statuses) { should_not be_empty }
        end
      end

      context "with a site_statuses association that has not been loaded" do
        let(:course) { create(:course, site_statuses: []) }

        it "uses #select on the association" do
          course_with_site_statuses_not_loaded = Course.find(course.id)
          allow(course_with_site_statuses_not_loaded.site_statuses)
            .to receive(:findable).and_return([])

          course_with_site_statuses_not_loaded.findable_site_statuses

          expect(course_with_site_statuses_not_loaded.site_statuses)
            .to have_received(:findable)
        end

        context "with a findable site" do
          let(:course) { create(:course, site_statuses: [findable]) }

          subject { Course.find(course.id) }

          its(:findable_site_statuses) { should_not be_empty }
        end

        context "with no findable sites" do
          let(:course) { create(:course, site_statuses: [suspended]) }

          subject { Course.find(course.id) }

          its(:findable_site_statuses) { should be_empty }
        end

        context "with at least one findable sites" do
          let(:course) { create(:course, site_statuses: [findable, suspended]) }

          subject { Course.find(course.id) }

          its(:findable_site_statuses) { should_not be_empty }
        end
      end
    end

    describe "#syncable_subjects" do
      let(:subject) { create :primary_subject, :primary }
      let(:subject_discontinued) { create :discontinued_subject }
      let(:subject_without_code) { create :primary_subject, :primary, subject_code: nil }
      let(:course) do
        create :course, subjects: [subject, modern_languages, subject_discontinued]
      end

      it "returns none-discontinued subjects that have a code present" do
        expect(course.syncable_subjects).to eq [subject]
      end

      context "with a subjects that has been loaded" do
        it "does not use where to reload subjects" do
          allow(course.subjects).to receive(:where)

          expect(course.syncable_subjects).to eq [subject]

          expect(course.subjects).not_to have_received(:where)
        end
      end
    end

    describe "#findable?" do
      context "when #findable_site_statuses returns site statuses" do
        it "returns true" do
          allow(course).to receive(:findable_site_statuses).and_return([findable])
          expect(course.findable?).to be_truthy
        end
      end

      context "when #findable_site_statuses returns no site statuses" do
        it "returns false" do
          allow(course).to receive(:findable_site_statuses).and_return([])
          expect(course.findable?).to be_falsey
        end
      end
    end

    describe "#has_vacancies?" do
      let(:findable_without_vacancies) { build(:site_status, :findable, :with_no_vacancies) }
      context "for a single site status that has vacancies" do
        let(:subject) {
          create(:course, site_statuses: [findable, with_any_vacancy])
        }

        its(:has_vacancies?) { should be true }
      end

      context "for a site status with vacancies and others without" do
        let(:findable_with_vacancies) { build(:site_status, :findable, :with_any_vacancy) }
        let(:subject) {
          create(:course, site_statuses: [findable_with_vacancies, findable_without_vacancies])
        }

        its(:has_vacancies?) { should be true }
      end

      context "when none of the sites have vacancies" do
        let(:subject) {
          create(:course, site_statuses: [findable_without_vacancies, findable_without_vacancies])
        }

        its(:has_vacancies?) { should be false }
      end

      context "when only discontinued and suspended site statuses have vacancies" do
        let(:findable_with_no_vacancies) { build(:site_status, :findable, :with_no_vacancies) }
        let(:published_suspended_with_any_vacancy) { build(:site_status, :published, :discontinued, :with_any_vacancy) }
        let(:published_discontinued_with_any_vacancy) { build(:site_status, :published, :suspended, :with_any_vacancy) }

        let(:subject) {
          create(:course, site_statuses: [findable_with_no_vacancies, published_suspended_with_any_vacancy, published_discontinued_with_any_vacancy])
        }

        its(:has_vacancies?) { should be false }
      end
    end

    describe "#has_vacancies? (when site_statuses not loaded)" do
      let(:findable_without_vacancies) { build(:site_status, :findable, :with_no_vacancies) }

      context "for a single site status that has vacancies" do
        let(:subject) {
          create(:course, site_statuses: [findable, with_any_vacancy]).reload
        }

        its(:has_vacancies?) { should be true }
      end

      context "for a site status with vacancies and others without" do
        let(:findable_with_vacancies) { build(:site_status, :findable, :with_any_vacancy) }
        let(:subject) {
          create(:course, site_statuses: [findable_with_vacancies, findable_without_vacancies]).reload
        }

        its(:has_vacancies?) { should be true }
      end

      context "when none of the sites have vacancies" do
        let(:subject) {
          create(:course, site_statuses: [findable_without_vacancies, findable_without_vacancies]).reload
        }

        its(:has_vacancies?) { should be false }
      end

      context "when only discontinued and suspended site statuses have vacancies" do
        let(:findable_with_no_vacancies) { build(:site_status, :findable, :with_no_vacancies) }
        let(:published_suspended_with_any_vacancy) { build(:site_status, :published, :discontinued, :with_any_vacancy) }
        let(:published_discontinued_with_any_vacancy) { build(:site_status, :published, :suspended, :with_any_vacancy) }

        let(:subject) {
          create(:course, site_statuses: [findable_with_no_vacancies, published_suspended_with_any_vacancy, published_discontinued_with_any_vacancy]).reload
        }

        its(:has_vacancies?) { should be false }
      end
    end

    describe "open_for_applications?" do
      let(:site_statuses) { [] }

      let(:applications_open_from) { Time.now.utc }

      let(:course) do
        create(:course,
               site_statuses: site_statuses,
               applications_open_from: applications_open_from)
      end

      let(:subject) {
        course
      }

      context "no site statuses" do
        context "applications_open_from is in present or past" do
          its(:open_for_applications?) { should be false }
        end
        context "applications_open_from is in future" do
          let(:applications_open_from) { Time.now.utc + 1.days }
          its(:open_for_applications?) { should be false }
        end
      end

      context "with site statuses" do
        context "with only a single findable site statuses" do
          let(:site_statuses) { [findable] }
          context "applications_open_from is in present or past" do
            its(:open_for_applications?) { should be true }
          end
          context "applications_open_from is in future" do
            let(:applications_open_from) { Time.now.utc + 1.days }
            its(:open_for_applications?) { should be false }
          end
        end

        context "with at least a single findable site statuses" do
          let(:site_statuses) do
            [default, findable, new_site_status,
             site_status_with_no_vacancies, suspended, with_any_vacancy]
          end

          context "applications_open_from is in present or past" do
            its(:open_for_applications?) { should be true }
          end
          context "applications_open_from is in future" do
            let(:applications_open_from) { Time.now.utc + 1.days }
            its(:open_for_applications?) { should be false }
          end
        end

        context "with no findable site statuses" do
          let(:site_statuses) do
            [default, new_site_status, site_status_with_no_vacancies,
             suspended, with_any_vacancy]
          end

          context "applications_open_from is in present or past" do
            its(:open_for_applications?) { should be false }
          end
          context "applications_open_from is in future" do
            let(:applications_open_from) { Time.now.utc + 1.days }
            its(:open_for_applications?) { should be false }
          end
        end
      end
    end

    describe "open_for_applications? (when site_statuses not loaded)" do
      let(:site_statuses) { [] }

      let(:applications_open_from) { Time.now.utc }

      let(:course) do
        create(:course,
               site_statuses: site_statuses,
               applications_open_from: applications_open_from)
      end

      let(:subject) {
        course.reload
      }

      context "no site statuses" do
        context "applications_open_from is in present or past" do
          its(:open_for_applications?) { should be false }
        end
        context "applications_open_from is in future" do
          let(:applications_open_from) { Time.now.utc + 1.days }
          its(:open_for_applications?) { should be false }
        end
      end

      context "with site statuses" do
        context "with only a single findable site statuses" do
          let(:site_statuses) { [findable] }
          context "applications_open_from is in present or past" do
            its(:open_for_applications?) { should be true }
          end
          context "applications_open_from is in future" do
            let(:applications_open_from) { Time.now.utc + 1.days }
            its(:open_for_applications?) { should be false }
          end
        end

        context "with at least a single findable site statuses" do
          let(:site_statuses) do
            [default, findable, new_site_status,
             site_status_with_no_vacancies, suspended, with_any_vacancy]
          end

          context "applications_open_from is in present or past" do
            its(:open_for_applications?) { should be true }
          end
          context "applications_open_from is in future" do
            let(:applications_open_from) { Time.now.utc + 1.days }
            its(:open_for_applications?) { should be false }
          end
        end

        context "with no findable site statuses" do
          let(:site_statuses) do
            [default, new_site_status, site_status_with_no_vacancies,
             suspended, with_any_vacancy]
          end

          context "applications_open_from is in present or past" do
            its(:open_for_applications?) { should be false }
          end
          context "applications_open_from is in future" do
            let(:applications_open_from) { Time.now.utc + 1.days }
            its(:open_for_applications?) { should be false }
          end
        end
      end
    end

    describe "ucas_status" do
      context "without any site statuses" do
        let(:subject) { create(:course) }

        its(:ucas_status) { should eq :new }
      end

      context "with a running site_status" do
        let(:subject) { create(:course, site_statuses: [findable]) }

        its(:ucas_status) { should eq :running }
      end

      context "with a new site_status" do
        let(:new) { build(:site_status, :new) }
        let(:subject) { create(:course, site_statuses: [new]) }

        its(:ucas_status) { should eq :new }
      end

      context "with a not running site_status" do
        let(:suspended) { build(:site_status, :suspended) }
        let(:subject) { create(:course, site_statuses: [suspended]) }

        its(:ucas_status) { should eq :not_running }
      end
    end

    describe "#not_new" do
      let(:new_course) do
        create(:course, site_statuses: [new_site_status])
      end

      let(:suspended_course_with_new_site) do
        create(:course, site_statuses: [suspended, new_site_status2])
      end

      let(:findable_course) do
        create(:course, site_statuses: [findable])
      end

      it "only returns courses that arent new" do
        new_course
        findable_course
        suspended_course_with_new_site

        expect(Course.not_new.count).to eq(2)
        expect(Course.not_new.first.sites.count).to eq(1)
        expect(Course.not_new.second.sites.count).to eq(1)
      end
    end

    its(:site_statuses) { should be_empty }
    its(:findable?) { should be false }
    its(:open_for_applications?) { should be false }
    its(:has_vacancies?) { should be false }
  end

  describe "#changed_since" do
    context "with no parameters" do
      let!(:old_course) { create(:course, age: 1.hour.ago) }
      let!(:course) { create(:course, age: 1.hour.ago) }

      subject { Course.changed_since(nil) }

      it { should include course }
      it { should include old_course }
    end

    context "with a course that was just updated" do
      let(:course) { create(:course, age: 1.hour.ago) }
      let!(:old_course) { create(:course, age: 1.hour.ago) }

      before { course.touch }

      subject { Course.changed_since(10.minutes.ago) }

      it { should include course }
      it { should_not include old_course }
    end

    context "with a course that has been changed less than a second after the given timestamp" do
      let(:timestamp) { 5.minutes.ago }
      let(:course) { create(:course, changed_at: timestamp + 0.001.seconds) }

      subject { Course.changed_since(timestamp) }

      it { should include course }
    end

    context "with a course that has been changed exactly at the given timestamp" do
      let(:timestamp) { 10.minutes.ago }
      let(:course) { create(:course, changed_at: timestamp) }

      subject { Course.changed_since(timestamp) }

      it { should_not include course }
    end
  end

  describe "#study_mode_description" do
    specs = {
      full_time: "full time",
      part_time: "part time",
      full_time_or_part_time: "full time or part time",
    }.freeze

    specs.each do |study_mode, expected_description|
      context study_mode.to_s do
        subject { create(:course, study_mode: study_mode) }
        its(:study_mode_description) { should eq(expected_description) }
      end
    end
  end

  describe "#description" do
    context "for a both full time and part time course" do
      subject {
        create(:course,
               study_mode: :full_time_or_part_time,
               program_type: :scitt_programme,
               qualification: :qts)
      }

      its(:description) { should eq("QTS, full time or part time") }
    end

    specs = {
      "QTS, full time or part time" => {
        study_mode: :full_time_or_part_time,
        program_type: :scitt_programme,
        qualification: :qts,
      },
      "PGCE with QTS full time with salary" => {
        study_mode: :full_time,
        program_type: :school_direct_salaried_training_programme,
        qualification: :pgce_with_qts,
      },
    }.freeze

    specs.each do |expected_description, course_attributes|
      context "for #{expected_description} course" do
        subject { create(:course, course_attributes) }
        its(:description) { should eq(expected_description) }
      end
    end

    context "for a salaried course" do
      subject {
        create(:course,
               study_mode: :full_time,
               program_type: :school_direct_salaried_training_programme,
               qualification: :pgce_with_qts)
      }

      its(:description) { should eq("PGCE with QTS full time with salary") }
    end

    context "for a teaching apprenticeship" do
      subject {
        create(:course,
               study_mode: :part_time,
               program_type: :pg_teaching_apprenticeship,
               qualification: :pgde_with_qts)
      }

      its(:description) { should eq("PGDE with QTS part time teaching apprenticeship") }
    end
  end

  describe "content_status" do
    let(:course) { create :course, enrichments: [enrichment] }

    context "when enrichment is published" do
      let(:enrichment) { create :course_enrichment, status: :published }

      subject { course.content_status }

      it { should eq :published }
    end

    context "when enrichment is rolled-over" do
      let(:enrichment) { create :course_enrichment, status: :rolled_over }

      subject { course.content_status }

      it { should eq :rolled_over }
    end

    context "when there are no enrichments" do
      let(:course) { create :course, enrichments: [] }

      subject { course.content_status }

      it { should eq :empty }
    end

    context "when there are no enrichments and the course is rolled-over" do
      let(:next_recruitment_cycle) { create :recruitment_cycle, :next }
      let(:next_provider) { create :provider, recruitment_cycle: next_recruitment_cycle }
      let(:course) { create :course, provider: next_provider, enrichments: [] }

      subject { course.content_status }

      it { should eq :rolled_over }
    end

    context "When the enrichments are withdrawn" do
      let(:enrichment) { create :course_enrichment, status: :withdrawn }

      it "should have a content status of withdrawn" do
        expect(course.content_status).to eq(:withdrawn)
      end
    end
  end

  describe "qualifications" do
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

  describe "#is_send?" do
    subject { create(:course) }
    its(:is_send?) { should be_falsey }

    context "with a SEND subject" do
      subject { create(:course, is_send: true) }
      its(:is_send?) { should be_truthy }
    end
  end

  context "gcse_subjects_required" do
    context "with primary level" do
      subject { create(:course, level: "primary") }
      its(:level) { should eq("primary") }
      its(:gcse_subjects_required) { should eq(%w[maths english science]) }
    end

    context "with secondary level" do
      subject { create(:course, level: "secondary") }
      its(:level) { should eq("secondary") }
      its(:gcse_subjects_required) { should eq(%w[maths english]) }
    end

    context "with secondary level" do
      subject { create(:course, level: "further_education") }
      its(:level) { should eq("further_education") }
      its(:gcse_subjects_required) { should eq([]) }
    end
  end

  context "bursaries and scholarships" do
    let!(:financial_incentive) { create(:financial_incentive, subject: modern_languages, bursary_amount: 255, scholarship: 1415, early_career_payments: 32) }
    subject { create(:course, level: "secondary", subjects: [modern_languages]) }

    it { should have_bursary }
    it { should have_scholarship_and_bursary }
    it { should have_early_career_payments }

    it { expect(subject.bursary_amount).to eq("255") }
    it { expect(subject.scholarship_amount).to eq("1415") }
  end

  context "entry requirements" do
    %i[maths science english].each do |gcse_subject|
      describe gcse_subject do
        it "is an enum" do
          expect(subject)
            .to define_enum_for(gcse_subject)
                  .backed_by_column_of_type(:integer)
                  .with_values(Course::ENTRY_REQUIREMENT_OPTIONS)
                  .with_suffix("for_#{gcse_subject}")
        end
      end
    end
  end

  describe "adding and removing sites on a course" do
    let(:provider) { build(:provider) }
      #this code will be removed and fixed properly in the next pr
    let(:new_site) { create(:site, provider: provider, code: "A") }
     #this code will be removed and fixed properly in the next pr
    let(:existing_site) { create(:site, provider: provider, code: "B") }
    let(:new_site_status) { subject.site_statuses.find_by!(site: new_site) }
    subject { create(:course, site_statuses: [existing_site_status]) }

    context "for running courses" do
      let(:existing_site_status) { create(:site_status, :running, :published, site: existing_site) }

      it "suspends the site when an existing site is removed" do
        expect { subject.remove_site!(site: existing_site) }.
          to change { existing_site_status.reload.status }.from("running").to("suspended")
      end

      it "adds a new site status and sets it to running when a new site is added" do
        expect { subject.add_site!(site: new_site) }.to change { subject.reload.site_statuses.size }.
          from(1).to(2)
        expect(new_site_status.status).to eq("running")
      end
    end

    context "for new courses" do
      let(:existing_site_status) { create(:site_status, :new, site: existing_site) }

      it "sets the site to new when a new site is added" do
        expect { subject.add_site!(site: new_site) }.to change { subject.reload.site_statuses.size }.
          from(1).to(2)
        expect(new_site_status.status).to eq("new_status")
      end

      it "keeps the site status as new when an existing site is added" do
        expect { subject.add_site!(site: existing_site) }.
          to_not change { existing_site_status.reload.status }.from("new_status")
      end

      it "removes the site status when an existing site is removed" do
        expect { subject.remove_site!(site: existing_site) }.to change { subject.reload.site_statuses.size }.
          from(1).to(0)
      end
    end

    context "for suspended courses" do
      let(:existing_site_status) { create(:site_status, :suspended, site: existing_site) }

      it "sets the site to running when a new site is added" do
        expect { subject.add_site!(site: new_site) }.to change { subject.reload.site_statuses.size }.
          from(1).to(2)
        expect(new_site_status.status).to eq("running")
      end

      it "sets the site to running when an existing site is added" do
        expect { subject.add_site!(site: existing_site) }.
          to change { existing_site_status.reload.status }.from("suspended").to("running")
      end
    end

    context "for courses without any training locations" do
      subject { create(:course, site_statuses: []) }

      it "sets the site to new when a new site is added" do
        expect { subject.add_site!(site: new_site) }.to change { subject.reload.site_statuses.size }.
          from(0).to(1)
        expect(new_site_status.status).to eq("new_status")
      end
    end

    context "for mixed courses with new and running locations" do
      let(:existing_site_status) { create(:site_status, :running, :published, site: existing_site) }
      #this code will be removed and fixed properly in the next pr
      let(:another_existing_site) { create(:site, code: "C", provider: provider) }
      let(:existing_new_site_status) { create(:site_status, :new, site: another_existing_site) }

      subject { create(:course, site_statuses: [existing_site_status, existing_new_site_status]) }

      it "adds a new site status and sets it to running when a new site is added" do
        expect { subject.add_site!(site: new_site) }.to change { subject.reload.site_statuses.size }.
          from(2).to(3)
        expect(new_site_status.status).to eq("running")
      end

      it "suspends the site when an existing site is removed" do
        expect { subject.remove_site!(site: existing_site) }.
          to change { existing_site_status.reload.status }.from("running").to("suspended")
      end
    end
  end

  describe "#accrediting_provider_description" do
    let(:accrediting_provider) { nil }
    let(:course) { create(:course, accrediting_provider: accrediting_provider) }
    subject { course.accrediting_provider_description }

    context "for courses without accrediting provider" do
      it { should be_nil }
    end

    context "for courses with accrediting provider" do
      let(:accrediting_provider) { build(:provider) }
      let(:course) { create(:course, provider: provider, accrediting_provider: accrediting_provider) }

      let(:provider) { build(:provider, accrediting_provider_enrichments: accrediting_provider_enrichments) }

      context "without any accrediting_provider_enrichments" do
        let(:accrediting_provider_enrichments) { nil }

        it { should be_nil }
      end

      context "with accrediting_provider_enrichments" do
        let(:accrediting_provider_enrichment_description) { Faker::Lorem.sentence.to_s }
        let(:accrediting_provider_enrichment) do
          {
            "UcasProviderCode" => accrediting_provider.provider_code,
            "Description" => accrediting_provider_enrichment_description,
          }
        end

        let(:accrediting_provider_enrichments) { [accrediting_provider_enrichment] }

        it { should match accrediting_provider_enrichment_description }
      end
    end
  end

  describe "#enrichments" do
    describe "#find_or_initialize_draft" do
      let(:course) { create(:course, enrichments: enrichments) }

      copyable_enrichment_attributes =
        %w[
          about_course
          course_length
          fee_details
          fee_international
          fee_uk_eu
          financial_support
          how_school_placements_work
          interview_process
          other_requirements
          personal_qualities
          qualifications
          salary_details
        ].freeze

      let(:actual_enrichment_attributes) do
        subject.attributes.slice(*copyable_enrichment_attributes)
      end

      subject { course.enrichments.find_or_initialize_draft }

      context "no enrichments" do
        let(:enrichments) { [] }

        it "sets all attributes to be nil" do
          expect(actual_enrichment_attributes.values).to be_all(&:nil?)
        end

        its(:id) { should be_nil }
        its(:last_published_timestamp_utc) { should be_nil }
        its(:status) { should eq "draft" }
      end

      context "with a draft enrichment" do
        let(:initial_draft_enrichment) { build(:course_enrichment, :initial_draft) }
        let(:enrichments) { [initial_draft_enrichment] }
        let(:expected_enrichment_attributes) { initial_draft_enrichment.attributes.slice(*copyable_enrichment_attributes) }

        it "has all the same attributes as the initial draft enrichment" do
          expect(actual_enrichment_attributes).to eq expected_enrichment_attributes
        end

        its(:id) { should_not be_nil }
        its(:last_published_timestamp_utc) { should eq initial_draft_enrichment.last_published_timestamp_utc }
        its(:status) { should eq "draft" }
      end

      context "with a published enrichment" do
        let(:published_enrichment) { build(:course_enrichment, :published) }
        let(:enrichments) { [published_enrichment] }
        let(:expected_enrichment_attributes) { published_enrichment.attributes.slice(*copyable_enrichment_attributes) }

        it "has all the same attributes as the published enrichment" do
          expect(actual_enrichment_attributes).to eq expected_enrichment_attributes
        end

        its(:id) { should be_nil }
        its(:last_published_timestamp_utc) { should be_within(1.second).of published_enrichment.last_published_timestamp_utc }
        its(:status) { should eq "draft" }
      end

      context "with a draft and published enrichment" do
        let(:published_enrichment) { build(:course_enrichment, :published) }
        let(:subsequent_draft_enrichment) { build(:course_enrichment, :subsequent_draft) }
        let(:enrichments) { [published_enrichment, subsequent_draft_enrichment] }
        let(:expected_enrichment_attributes) { subsequent_draft_enrichment.attributes.slice(*copyable_enrichment_attributes) }

        it "has all the same attributes as the subsequent draft enrichment" do
          expect(actual_enrichment_attributes).to eq expected_enrichment_attributes
        end

        its(:id) { should_not be_nil }
        its(:last_published_timestamp_utc) { should be_within(1.second).of subsequent_draft_enrichment.last_published_timestamp_utc }
        its(:status) { should eq "draft" }
      end
    end
  end

  describe "#syncable?" do
    let(:courses_subjects) { [find_or_create(:secondary_subject, :biology)] }
    let(:site_status) { build(:site_status, :findable) }

    subject { create(:course, :infer_level, subjects: courses_subjects, site_statuses: [site_status]) }

    its(:syncable?) { should be_truthy }

    context "invalid courses" do
      context "course which has only discontinued subject subject type" do
        let(:courses_subjects) { [find_or_create(:discontinued_subject, :humanities)] }
        its(:syncable?) { should be_falsey }
      end

      context "course which has only modern lanaguage secondary subject type" do
        let(:courses_subjects) { [find_or_create(:secondary_subject, :modern_languages)] }
        its(:syncable?) { should be_falsey }
      end

      context "course which has a dfe subject, but no findable site statuses" do
        let(:site_status) { build(:site_status, :suspended) }
        its(:syncable?) { should be_falsey }
      end

      context "course which has a findable site status, but no dfe_subject" do
        let(:courses_subjects) { [] }
        its(:syncable?) { should be_falsey }
      end
    end
  end

  describe "#should_sync?" do
    let(:course_enrichment) { build :course_enrichment, :published }
    let(:site_status) { build(:site_status, :findable) }
    let(:provider) { build(:provider) }
    subject { create(:course, provider: provider, site_statuses: [site_status], enrichments: [course_enrichment]) }

    its(:should_sync?) { should be_truthy }

    context "course not yet published" do
      let(:course_enrichment) { build :course_enrichment }
      its(:should_sync?) { should be_falsey }
    end

    context "course in next cycle" do
      let(:provider) { build :provider, :next_recruitment_cycle }
      its(:should_sync?) { should be_falsey }
    end
  end

  describe "self.get_by_codes" do
    it "should return the found course" do
      expect(Course.get_by_codes(
               course.recruitment_cycle.year,
               course.provider.provider_code,
               course.course_code,
             )).to eq course
    end
  end

  describe "next_recruitment_cycle?" do
    subject { course.next_recruitment_cycle? }

    context "course is in current recruitment cycle" do
      it { should be_falsey }
    end

    context "course is in the next recruitment cycle" do
      let(:recruitment_cycle) { create :recruitment_cycle, :next }
      let(:provider)          { create :provider, recruitment_cycle: recruitment_cycle }
      let(:course) { create :course, provider: provider }

      it { should be_truthy }
    end
  end

  describe "#discard" do
    context "new course" do
      let!(:subject) do
        course = create(:course)

        site = create(:site)
        create(:site_status, :new, site: site, course: course)

        course
      end

      context "before discarding" do
        its(:discarded?) { should be false }

        it "is in kept" do
          expect(described_class.kept.size).to eq(1)
        end

        it "is not in discarded" do
          expect(described_class.discarded.size).to eq(0)
        end
      end

      context "after discarding" do
        before do
          subject.discard
        end

        its(:discarded?) { should be true }

        it "is not in kept" do
          expect(described_class.kept.size).to eq(0)
        end

        it "is in discarded" do
          expect(described_class.discarded.size).to eq(1)
        end
      end

      context "incorrect actions" do
        it "raises error when deleted and course status is running" do
          course = subject

          site = create(:site)
          create(:site_status, :running, :published, site: site, course: course)

          expect { course.discard }.to raise_error(
            "You cannot delete a running course (Course: #{course}, Provider: #{course.provider_id})",
          )
        end
      end
    end
  end

  describe "#applications_open_from" do
    context "a new course with a given date" do
      let(:applications_open_from) { Date.today }
      let(:subject) { create(:course, applications_open_from: applications_open_from) }

      its(:applications_open_from) { should eq applications_open_from }
    end

    context "a new course within a recruitment cycle" do
      let(:recruitment_cycle) { build :recruitment_cycle, :next }
      let(:provider)          { build :provider, recruitment_cycle: recruitment_cycle }
      let(:subject) { create :course, :applications_open_from_not_set, provider: provider }

      its(:applications_open_from) { should eq recruitment_cycle.application_start_date }
    end
  end

  describe "#is_send=" do
    let(:subject) { build(:course) }

    before do
      subject.is_send = value
    end

    context "when value is `true`" do
      let(:value) { true }

      its(:is_send) { is_expected.to be(true) }
    end

    context 'when value is `"true"`' do
      let(:value) { "true" }

      its(:is_send) { is_expected.to be(true) }
    end

    context "when value is `1`" do
      let(:value) { 1 }

      its(:is_send) { is_expected.to be(true) }
    end

    context "when value is `0`" do
      let(:value) { 0 }

      its(:is_send) { is_expected.to be(false) }
    end

    context "when value is `false`" do
      let(:value) { false }

      its(:is_send) { is_expected.to be(false) }
    end

    context 'when value is `"false"`' do
      let(:value) { "false" }

      its(:is_send) { is_expected.to be(false) }
    end

    context "when value is a string that is not like a boolean" do
      let(:value) { "blah-blah" }

      its(:is_send) { is_expected.to be_nil }
      it { is_expected.to_not be_valid }
    end
  end

  describe "#self_accredited?" do
    let(:provider) { build(:provider) }

    context "when self accredited" do
      subject { create(:course, provider: provider) }
      its(:self_accredited?) { should be_truthy }
    end

    context "when self accredited" do
      subject { create(:course, :with_accrediting_provider, provider: provider) }
      its(:self_accredited?) { should be_falsey }
    end
  end

  describe "#course_params_assignable" do
    describe "when setting the entry requirement" do
      it "can assign a valid value" do
        expect(course.course_params_assignable(maths: "equivalence_test")).to eq(true)
        expect(course.errors.messages).to eq(enrichments: [])
      end

      it "cannot be assigned an invalid value" do
        expect(course.course_params_assignable(maths: "test")).to eq(false)
        expect(course.errors.messages).to eq(enrichments: [], maths: ["is invalid"])
      end
    end

    describe "when setting the qualification" do
      it "can assign a valid qualification" do
        expect(course.course_params_assignable(qualification: "pgce_with_qts")).to eq(true)
        expect(course.errors.messages).to eq(enrichments: [])
      end

      it "cannot assign invalid qualification" do
        expect(course.course_params_assignable(qualification: "invalid")).to eq(false)
        expect(course.errors.messages).to eq(enrichments: [], qualification: ["is invalid"])
      end
    end

    describe "for publishing" do
      let(:user) { create(:user) }

      context "when not published" do
        let(:enrichment) { create(:course_enrichment, :initial_draft) }
        let(:course) { create(:course, enrichments: [enrichment]) }

        it "can assign to SEND" do
          expect(course.course_params_assignable(is_send: true)).to eq(true)
          expect(course.errors.messages).to eq(enrichments: [])
        end

        it "can assign to applications open from" do
          expect(course.course_params_assignable(applications_open_from: "25/08/2019")).to eq(true)
          expect(course.errors.messages).to eq(enrichments: [])
        end

        it "can assign to applications open from" do
          expect(course.course_params_assignable(application_start_date: "25/08/2019")).to eq(true)
          expect(course.errors.messages).to eq(enrichments: [])
        end
      end

      context "when published" do
        let(:enrichment) { create(:course_enrichment, :published) }
        let(:course) { create(:course, enrichments: [enrichment]) }

        it "cannot assign to SEND" do
          expect(course.course_params_assignable(is_send: true)).to eq(false)
          expect(course.errors.messages).to eq(enrichments: [], is_send: ["cannot be changed after publish"])
        end

        it "cannot assign to applications open from" do
          expect(course.course_params_assignable(applications_open_from: "25/08/2019")).to eq(false)
          expect(course.errors.messages).to eq(enrichments: [], applications_open_from: ["cannot be changed after publish"])
        end

        it "cannot assign to applications open from" do
          expect(course.course_params_assignable(application_start_date: "25/08/2019")).to eq(false)
          expect(course.errors.messages).to eq(enrichments: [], application_start_date: ["cannot be changed after publish"])
        end
      end
    end
  end

  describe "#is_published?" do
    context "course is not published" do
      let(:enrichment) { create(:course_enrichment, :initial_draft) }
      let(:course) { create(:course, enrichments: [enrichment]) }

      it "returns false" do
        expect(course.is_published?).to eq(false)
      end
    end

    context "course is published" do
      let(:enrichment) { create(:course_enrichment, :published) }
      let(:course) { create(:course, enrichments: [enrichment]) }

      it "returns true" do
        expect(course.is_published?).to eq(true)
      end
    end

    context "course is published with unpublished changes" do
      let(:enrichment) { create(:course_enrichment, :subsequent_draft) }
      let(:course) { create(:course, enrichments: [enrichment]) }

      it "returns true" do
        expect(course.content_status).to eq(:published_with_unpublished_changes)
        expect(course.is_published?).to eq(true)
      end
    end

    context "course is withdrawn" do
      let(:enrichment) { create(:course_enrichment, :withdrawn) }
      let(:course) { create(:course, enrichments: [enrichment]) }

      it "returns false" do
        expect(course.content_status).to eq(:withdrawn)
        expect(course.is_published?).to eq(false)
      end
    end
  end
end
