# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseEnrichment do
  describe "associations" do
    it { is_expected.to belong_to(:course) }
  end

  describe "defaults" do
    it "defaults version to 1" do
      expect(build(:course_enrichment).version).to eq 1
    end
  end

  describe "default v2 if feature flag is enabled" do
    before do
      allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(true)
    end

    it "defaults version to 2" do
      expect(build(:course_enrichment).version).to eq 2
    end
  end

  describe "overwrites default version" do
    it "can be set to 2" do
      expect(build(:course_enrichment, :v2).version).to eq 2
    end

    it "can be set to 1" do
      expect(build(:course_enrichment, :v1).version).to eq 1
    end
  end

  #
  # Versioned fields
  #
  it_behaves_like "versioned_presence_field",
                  field: :about_course,
                  required_in: { 1 => true, 2 => false }, # This is required in v1 but not in v2
                  word_limit: 400

  it_behaves_like "versioned_presence_field",
                  field: :interview_process,
                  required_in: { 1 => false, 2 => false },
                  word_limit: [250, 200]

  it_behaves_like "versioned_presence_field",
                  field: :how_school_placements_work,
                  required_in: { 1 => true, 2 => false },
                  word_limit: 350

  it_behaves_like "versioned_presence_field",
                  field: :placement_selection_criteria,
                  required_in: { 1 => false, 2 => true },
                  word_limit: 50

  it_behaves_like "versioned_presence_field",
                  field: :duration_per_school,
                  required_in: { 1 => false, 2 => true },
                  word_limit: 50

  it_behaves_like "versioned_presence_field",
                  field: :theoretical_training_location,
                  required_in: { 1 => false, 2 => true },
                  word_limit: 50

  it_behaves_like "versioned_presence_field",
                  field: :theoretical_training_duration,
                  required_in: { 1 => false, 2 => false },
                  word_limit: 50

  it_behaves_like "versioned_presence_field",
                  field: :placement_school_activities,
                  required_in: { 1 => false, 2 => true },
                  word_limit: 150

  it_behaves_like "versioned_presence_field",
                  field: :support_and_mentorship,
                  required_in: { 1 => false, 2 => false },
                  word_limit: 50

  it_behaves_like "versioned_presence_field",
                  field: :theoretical_training_activities,
                  required_in: { 1 => false, 2 => true },
                  word_limit: 150

  it_behaves_like "versioned_presence_field",
                  field: :assessment_methods,
                  required_in: { 1 => false, 2 => false },
                  word_limit: 50

  it_behaves_like "versioned_presence_field",
                  field: :interview_location,
                  required_in: { 1 => false, 2 => false }
  #
  # Fields required for all versions
  #
  describe "course_length" do
    subject(:record) { build(:course_enrichment, course_length:) }

    let(:course_length) { "1 year" }

    context "nil" do
      let(:course_length) { nil }

      it { is_expected.to be_valid } # draft
      it { is_expected.not_to be_valid(:publish) }
    end
  end

  #
  # Conditional fee fields (fee-based only)
  #
  # fee_conditional = ->(rec) { rec.course.funding_type == "fee" } removed this functionality, can be added below to the shared example if needed
  # Conditional logic is implemented on the shared example, however I have not added it here as the fields.
  it_behaves_like "versioned_presence_field",
                  field: :fee_schedule,
                  required_in: { 1 => false, 2 => false },
                  word_limit: 50

  it_behaves_like "versioned_presence_field",
                  field: :additional_fees,
                  required_in: { 1 => false, 2 => false },
                  word_limit: 50

  it_behaves_like "versioned_presence_field",
                  field: :financial_support,
                  required_in: { 1 => false, 2 => false },
                  word_limit: [250, 50]

  #
  # Existing specs we already had
  #
  describe "#publish" do
    let(:user) { create(:user) }

    context "validates version 1 enrichment and fails to publish" do
      subject(:record) { create(:course_enrichment, :v1, course:) }

      let(:course) { create(:course) }

      it "is not valid to publish v2" do
        allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(true)
        expect(record).not_to be_valid(:publish)
        expect(record.errors[:placement_school_activities]).to include("can't be blank")
        expect(record.reload).to be_draft
      end
    end

    context "initial draft" do
      subject(:record) { create(:course_enrichment, :initial_draft, created_at: 1.day.ago, updated_at: 20.minutes.ago) }

      before { record.publish(user) }

      it { is_expected.to be_published }
      its(:updated_by_user_id) { is_expected.to eq user.id }
      its(:updated_at) { is_expected.to be_within(1.second).of Time.current.utc }
      its(:last_published_timestamp_utc) { is_expected.to be_within(1.second).of Time.current.utc }
    end

    context "subsequent draft" do
      subject(:record) { create(:course_enrichment, :subsequent_draft, created_at: 1.day.ago, updated_at: 20.minutes.ago) }

      before { record.publish(user) }

      it { is_expected.to be_published }
      its(:updated_by_user_id) { is_expected.to eq user.id }
      its(:updated_at) { is_expected.to be_within(1.second).of Time.current.utc }
      its(:last_published_timestamp_utc) { is_expected.to be_within(1.second).of Time.current.utc }
    end
  end

  describe "#has_been_published_before?" do
    it "is false for an initial draft" do
      expect(create(:course_enrichment, :initial_draft)).not_to have_been_published_before
    end

    it "is true for published items" do
      expect(create(:course_enrichment, :published)).to have_been_published_before
    end

    it "is true for subsequent drafts" do
      expect(create(:course_enrichment, :subsequent_draft)).to have_been_published_before
    end
  end

  describe ".most_recent" do
    let!(:older) { create(:course_enrichment, :published, created_at: 1.day.ago) }
    let!(:newer) { create(:course_enrichment, :published) }

    it "orders by created_at desc" do
      expect(described_class.most_recent).to eq [newer, older]
    end
  end

  describe "#unpublish" do
    subject(:record) { create(:course_enrichment, :published, last_published_timestamp_utc: timestamp, course:) }

    let(:provider) { create(:provider) }
    let(:course)   { create(:course, provider:) }
    let(:timestamp) { Time.utc(2017, 1, 1) }

    it "to initial draft resets last_published_timestamp_utc" do
      expect { record.unpublish(initial_draft: true) }.to change { record.reload.last_published_timestamp_utc }
        .from(timestamp).to(nil)
    end

    it "to subsequent draft keeps last_published_timestamp_utc" do
      expect { record.unpublish(initial_draft: false) }.not_to(change { record.reload.last_published_timestamp_utc })
    end
  end

  describe "#withdraw" do
    it "sets status to withdrawn" do
      enrichment = create(:course_enrichment, :published)
      enrichment.withdraw
      expect(enrichment.status).to eq("withdrawn")
    end
  end
end
