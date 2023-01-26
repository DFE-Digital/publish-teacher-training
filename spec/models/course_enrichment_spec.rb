require "rails_helper"

describe CourseEnrichment do
  subject { build(:course_enrichment) }

  describe "associations" do
    it { is_expected.to belong_to(:course) }
  end

  describe "#has_been_published_before?" do
    context "when the enrichment is an initial draft" do
      subject { create(:course_enrichment, :initial_draft) }

      it { is_expected.not_to have_been_published_before }
    end

    context "when the enrichment is published" do
      subject { create(:course_enrichment, :published) }

      it { is_expected.to have_been_published_before }
    end

    context "when the enrichment is a subsequent draft" do
      subject { create(:course_enrichment, :subsequent_draft) }

      it { is_expected.to have_been_published_before }
    end
  end

  describe "#publish" do
    let(:user) { create(:user) }

    context "when the enrichment is an initial draft" do
      subject { create(:course_enrichment, :initial_draft, created_at: 1.day.ago, updated_at: 20.minutes.ago) }

      before do
        subject.publish(user)
      end

      it { is_expected.to be_published }
      its(:updated_at) { is_expected.to be_within(1.second).of Time.now.utc }
      its(:last_published_timestamp_utc) { is_expected.to be_within(1.second).of Time.now.utc }
      its(:updated_by_user_id) { is_expected.to eq user.id }
    end

    context "when the enrichment is a subsequent draft" do
      subject { create(:course_enrichment, :subsequent_draft, created_at: 1.day.ago, updated_at: 20.minutes.ago) }

      before do
        subject.publish(user)
      end

      it { is_expected.to be_published }
      its(:updated_at) { is_expected.to be_within(1.second).of Time.now.utc }
      its(:last_published_timestamp_utc) { is_expected.to be_within(1.second).of Time.now.utc }
      its(:updated_by_user_id) { is_expected.to eq user.id }
    end
  end

  describe ".most_recent" do
    let!(:old_enrichment) { create(:course_enrichment, :published, created_at: Date.yesterday) }
    let!(:new_enrichment) { create(:course_enrichment, :published) }

    it "orders by created_at descending" do
      expect(CourseEnrichment.most_recent).to eq([new_enrichment, old_enrichment])
    end
  end

  describe "about_course attribute" do
    let(:about_course_text) { "this course is great" }

    subject { build(:course_enrichment, about_course: about_course_text) }

    context "with over 400 words" do
      let(:about_course_text) { Faker::Lorem.sentence(word_count: 400 + 1) }

      it { is_expected.not_to be_valid }
    end

    context "when nil" do
      let(:about_course_text) { nil }

      it { is_expected.to be_valid }

      describe "on publish" do
        it { is_expected.not_to be_valid :publish }
      end
    end
  end

  describe "course_length attribute" do
    let(:course_length_text) { "this course is great" }

    subject { build(:course_enrichment, course_length: course_length_text) }

    context "when nil" do
      let(:course_length_text) { nil }

      it { is_expected.to be_valid }

      describe "on publish" do
        it { is_expected.not_to be_valid :publish }
      end
    end
  end

  describe "how_school_placements_work attribute" do
    let(:how_school_placements_work_text) { "this course is great" }

    subject { build(:course_enrichment, how_school_placements_work: how_school_placements_work_text) }

    context "with over 400 words" do
      let(:how_school_placements_work_text) { Faker::Lorem.sentence(word_count: 400 + 1) }

      it { is_expected.not_to be_valid }
    end

    context "when nil" do
      let(:how_school_placements_work_text) { nil }

      it { is_expected.to be_valid }

      describe "on publish" do
        it { is_expected.not_to be_valid :publish }
      end
    end
  end

  describe "interview_process attribute" do
    let(:interview_process_text) { "this course is great" }

    subject { build(:course_enrichment, interview_process: interview_process_text) }

    context "with over 250 words" do
      let(:interview_process_text) { Faker::Lorem.sentence(word_count: 250 + 1) }

      it { is_expected.not_to be_valid }
    end
  end

  describe "required_qualifications attribute" do
    let(:required_qualifications_text) { "this course is great" }
    let(:recruitment_cycle) { build(:recruitment_cycle, year: "2021") }
    let(:provider) { build(:provider, recruitment_cycle:) }
    let(:course) { build(:course, provider:) }

    subject { build(:course_enrichment, required_qualifications: required_qualifications_text, course:) }

    context "with over 100 words" do
      let(:required_qualifications_text) { Faker::Lorem.sentence(word_count: 100 + 1) }

      it { is_expected.not_to be_valid }
    end

    context "when nil" do
      let(:required_qualifications_text) { nil }

      it { is_expected.to be_valid }

      describe "on publish" do
        context "in recruitment cycle 2021" do
          it { is_expected.not_to be_valid :publish }
        end

        context "in recruitment cycle 2022" do
          let(:recruitment_cycle) { build(:recruitment_cycle, year: "2022") }

          it { is_expected.to be_valid :publish }
        end
      end
    end
  end

  describe "personal_qualities attribute" do
    let(:personal_qualities_text) { "this course is great" }

    subject { build(:course_enrichment, personal_qualities: personal_qualities_text) }

    context "with over 100 words" do
      let(:personal_qualities_text) { Faker::Lorem.sentence(word_count: 100 + 1) }

      it { is_expected.not_to be_valid }
    end
  end

  describe "other_requirements attribute" do
    let(:other_requirements_text) { "this course is great" }

    subject { build(:course_enrichment, other_requirements: other_requirements_text) }

    context "with over 100 words" do
      let(:other_requirements_text) { Faker::Lorem.sentence(word_count: 100 + 1) }

      it { is_expected.not_to be_valid }
    end
  end

  describe "salary_details attribute" do
    let(:salary_details_text) { "this course is great" }

    let(:salaried_course) { build(:course, :with_salary) }

    subject { build(:course_enrichment, salary_details: salary_details_text, course: salaried_course) }

    context "with over 250 words" do
      let(:salary_details_text) { Faker::Lorem.sentence(word_count: 250 + 1) }

      it { is_expected.not_to be_valid }
    end

    context "when nil" do
      let(:salary_details_text) { nil }

      it { is_expected.to be_valid }

      describe "on publish" do
        it { is_expected.not_to be_valid :publish }
      end
    end
  end

  describe "validation for publish" do
    let(:course_enrichment) { build(:course_enrichment, :with_fee_based_course) }

    subject { course_enrichment }

    context "fee based course" do
      it { is_expected.to validate_presence_of(:fee_uk_eu).on(:publish) }
      it { is_expected.to validate_presence_of(:fee_uk_eu).on(:publish) }
      it { is_expected.to validate_numericality_of(:fee_uk_eu).on(:publish) }
      it { is_expected.to validate_numericality_of(:fee_international).on(:publish) }

      it "validates maximum word count for interview_process" do
        course_enrichment.interview_process = Faker::Lorem.sentence(word_count: 250 + 1)

        expect(course_enrichment).not_to be_valid :publish
        expect(course_enrichment.errors[:interview_process]).to be_present
      end

      it "validates maximum word count for fee_details" do
        course_enrichment.fee_details = Faker::Lorem.sentence(word_count: 250 + 1)

        expect(course_enrichment).not_to be_valid :publish
        expect(course_enrichment.errors[:fee_details]).to be_present
      end

      context "salary based fields" do
        it "does not validates maximum word count for salary_details" do
          course_enrichment.salary_details = Faker::Lorem.sentence(word_count: 250 + 1)

          expect(course_enrichment).to be_valid :publish
          expect(course_enrichment.errors[:salary_details]).to be_empty
        end

        it { is_expected.not_to validate_presence_of(:salary_details).on(:publish) }
      end
    end

    context "salary based course" do
      let(:course_enrichment) { build(:course_enrichment, :with_salary_based_course) }

      it { is_expected.to validate_presence_of(:salary_details).on(:publish) }
      it { is_expected.not_to validate_presence_of(:fee_uk_eu).on(:publish) }
      it { is_expected.not_to validate_numericality_of(:fee_uk_eu).on(:publish) }
      it { is_expected.not_to validate_numericality_of(:fee_international).on(:publish) }

      it "validates maximum word count for required_qualifications" do
        course_enrichment.required_qualifications = Faker::Lorem.sentence(word_count: 100 + 1)

        expect(course_enrichment).not_to be_valid :publish
        expect(course_enrichment.errors[:required_qualifications]).to be_present
      end

      it "validates maximum word count for salary_details" do
        course_enrichment.salary_details = Faker::Lorem.sentence(word_count: 250 + 1)

        expect(course_enrichment).not_to be_valid :publish
        expect(course_enrichment.errors[:salary_details]).to be_present
      end

      context "fee based fields" do
        it "does not validates maximum word count for fee_details" do
          course_enrichment.fee_details = Faker::Lorem.sentence(word_count: 250 + 1)

          expect(course_enrichment).to be_valid :publish
          expect(course_enrichment.errors[:fee_details]).to be_empty
        end

        it { is_expected.not_to validate_presence_of(:fee_uk_eu).on(:publish) }
      end
    end
  end

  describe "#unpublish" do
    let(:provider) { create(:provider) }
    let(:course) { create(:course, provider:) }
    let(:last_published_timestamp_utc) { Date.new(2017, 1, 1) }

    subject do
      create(:course_enrichment, :published,
        last_published_timestamp_utc:,
        course:)
    end

    describe "to initial draft" do
      it "sets the course to draft" do
        expect { subject.unpublish(initial_draft: true) }.to change { subject.reload.status }
          .from("published")
          .to("draft")
      end

      it "sets the last_published_timestamp_utc to nil" do
        expect { subject.unpublish(initial_draft: true) }.to change { subject.reload.last_published_timestamp_utc }
          .from(last_published_timestamp_utc)
          .to(nil)
      end
    end

    describe "to subsequent draft" do
      it "sets the course to draft" do
        expect { subject.unpublish(initial_draft: false) }.to change { subject.reload.status }
          .from("published")
          .to("draft")
      end

      it "keeps the last_published_timestamp_utc as is" do
        expect { subject.unpublish(initial_draft: false) }.not_to(change { subject.reload.last_published_timestamp_utc })
      end
    end
  end

  describe "#withdraw" do
    let(:enrichment) { create(:course_enrichment, :published) }

    it "sets the status to withdrawn" do
      enrichment.withdraw

      expect(enrichment.status).to eq("withdrawn")
    end
  end
end
