# == Schema Information
#
# Table name: course_enrichment
#
#  id                           :integer          not null, primary key
#  created_by_user_id           :integer
#  created_at                   :datetime         not null
#  provider_code                :text             not null
#  json_data                    :jsonb
#  last_published_timestamp_utc :datetime
#  status                       :integer          not null
#  ucas_course_code             :text             not null
#  updated_by_user_id           :integer
#  updated_at                   :datetime         not null
#

require 'rails_helper'

describe CourseEnrichment, type: :model do
  subject { build :course_enrichment }

  describe 'associations' do
    it 'belongs to a provider' do
      expect(subject).to belong_to(:provider)
                           .with_foreign_key(:provider_code)
                           .with_primary_key(:provider_code)
    end

    it 'belongs to a course' do
      expect(subject).to belong_to(:course)
                           .with_foreign_key(:ucas_course_code)
                           .with_primary_key(:course_code)
    end
  end

  describe '#has_been_published_before?' do
    context 'when the enrichment is an initial draft' do
      subject { create(:course_enrichment, :initial_draft) }
      it { should_not have_been_published_before }
    end

    context 'when the enrichment is published' do
      subject { create(:course_enrichment, :published) }
      it { should have_been_published_before }
    end

    context 'when the enrichment is a subsequent draft' do
      subject { create(:course_enrichment, :subsequent_draft) }
      it { should have_been_published_before }
    end
  end

  describe '#publish' do
    let(:user) { create(:user) }

    context 'when the enrichment is an initial draft' do
      subject { create(:course_enrichment, :initial_draft, created_at: 1.day.ago, updated_at: 20.minutes.ago) }

      before do
        subject.publish(user)
      end

      it { should be_published }
      its(:updated_at) { should be_within(1.second).of Time.now.utc }
      its(:last_published_timestamp_utc) { should be_within(1.second).of Time.now.utc }
      its(:updated_by_user_id) { should eq user.id }
    end

    context 'when the enrichment is a subsequent draft' do
      subject { create(:course_enrichment, :subsequent_draft, created_at: 1.day.ago, updated_at: 20.minutes.ago) }

      before do
        subject.publish(user)
      end

      it { should be_published }
      its(:updated_at) { should be_within(1.second).of Time.now.utc }
      its(:last_published_timestamp_utc) { should be_within(1.second).of Time.now.utc }
      its(:updated_by_user_id) { should eq user.id }
    end
  end

  describe '.latest_first' do
    let!(:old_enrichment) do
      create(:course_enrichment, :published, created_at: Date.yesterday)
    end
    let!(:new_enrichment) { create(:course_enrichment, :published) }

    it 'returns the new enrichment first' do
      expect(CourseEnrichment.latest_first.first).to eq new_enrichment
      expect(CourseEnrichment.latest_first.last).to eq old_enrichment
    end
  end

  describe 'about_course attribute' do
    let(:about_course_text) { 'this course is great' }

    subject { build :course_enrichment, about_course: about_course_text }

    context 'with over 400 words' do
      let(:about_course_text) { Faker::Lorem.sentence(400 + 1) }

      it { should_not be_valid }
    end

    context 'when nil' do
      let(:about_course_text) { nil }

      it { should be_valid }

      describe 'on publish' do
        it { should_not be_valid :publish }
      end
    end
  end

  describe 'course_length attribute' do
    let(:course_length_text) { 'this course is great' }

    subject { build :course_enrichment, course_length: course_length_text }

    context 'when nil' do
      let(:course_length_text) { nil }

      it { should be_valid }

      describe 'on publish' do
        it { should_not be_valid :publish }
      end
    end
  end

  describe 'how_school_placements_work attribute' do
    let(:how_school_placements_work_text) { 'this course is great' }

    subject { build :course_enrichment, how_school_placements_work: how_school_placements_work_text }

    context 'with over 400 words' do
      let(:how_school_placements_work_text) { Faker::Lorem.sentence(400 + 1) }

      it { should_not be_valid }
    end

    context 'when nil' do
      let(:how_school_placements_work_text) { nil }

      it { should be_valid }

      describe 'on publish' do
        it { should_not be_valid :publish }
      end
    end
  end

  describe 'interview_process attribute' do
    let(:interview_process_text) { 'this course is great' }

    subject { build :course_enrichment, interview_process: interview_process_text }

    context 'with over 250 words' do
      let(:interview_process_text) { Faker::Lorem.sentence(250 + 1) }

      it { should_not be_valid }
    end
  end

  describe 'qualifications attribute' do
    let(:qualifications_text) { 'this course is great' }

    subject { build :course_enrichment, qualifications: qualifications_text }

    context 'with over 100 words' do
      let(:qualifications_text) { Faker::Lorem.sentence(100 + 1) }

      it { should_not be_valid }
    end

    context 'when nil' do
      let(:qualifications_text) { nil }

      it { should be_valid }

      describe 'on publish' do
        it { should_not be_valid :publish }
      end
    end
  end

  describe 'personal_qualities attribute' do
    let(:personal_qualities_text) { 'this course is great' }

    subject { build :course_enrichment, personal_qualities: personal_qualities_text }

    context 'with over 100 words' do
      let(:personal_qualities_text) { Faker::Lorem.sentence(100 + 1) }

      it { should_not be_valid }
    end
  end

  describe 'other_requirements attribute' do
    let(:other_requirements_text) { 'this course is great' }

    subject { build :course_enrichment, other_requirements: other_requirements_text }

    context 'with over 100 words' do
      let(:other_requirements_text) { Faker::Lorem.sentence(100 + 1) }

      it { should_not be_valid }
    end
  end

  describe 'salary_details attribute' do
    let(:salary_details_text) { 'this course is great' }

    subject(:salaried_course) { build :course, :with_salary }
    subject { build :course_enrichment, salary_details: salary_details_text, course: salaried_course }

    context 'with over 250 words' do
      let(:salary_details_text) { Faker::Lorem.sentence(250 + 1) }

      it { should_not be_valid }
    end

    context 'when nil' do
      let(:salary_details_text) { nil }

      it { should be_valid }

      describe 'on publish' do
        it { should_not be_valid :publish }
      end
    end
  end

  describe 'validation for publish' do
    let(:course_enrichment) { build(:course_enrichment, :with_fee_based_course) }
    subject { course_enrichment }

    context 'fee based course' do
      it { should validate_presence_of(:fee_uk_eu).on(:publish) }
      it { should validate_presence_of(:qualifications).on(:publish) }
      it { should validate_presence_of(:fee_uk_eu).on(:publish) }
      it { should validate_numericality_of(:fee_uk_eu).on(:publish) }
      it { should validate_numericality_of(:fee_international).on(:publish) }

      it 'validates maximum word count for interview_process' do
        course_enrichment.interview_process = Faker::Lorem.sentence(250 + 1)

        expect(course_enrichment).not_to be_valid :publish
        expect(course_enrichment.errors[:interview_process]).to be_present
      end

      it 'validates maximum word count for fee_details' do
        course_enrichment.fee_details = Faker::Lorem.sentence(250 + 1)

        expect(course_enrichment).not_to be_valid :publish
        expect(course_enrichment.errors[:fee_details]).to be_present
      end

      context 'salary based fields' do
        it 'does not validates maximum word count for salary_details' do
          course_enrichment.salary_details = Faker::Lorem.sentence(250 + 1)

          expect(course_enrichment).to be_valid :publish
          expect(course_enrichment.errors[:salary_details]).to be_empty
        end

        it { should_not validate_presence_of(:salary_details).on(:publish) }
      end
    end

    context 'salary based course' do
      let(:course_enrichment) { build(:course_enrichment, :with_salary_based_course) }

      it { should validate_presence_of(:salary_details).on(:publish) }
      it { should validate_presence_of(:qualifications).on(:publish) }
      it { should_not validate_presence_of(:fee_uk_eu).on(:publish) }
      it { should_not validate_numericality_of(:fee_uk_eu).on(:publish) }
      it { should_not validate_numericality_of(:fee_international).on(:publish) }

      it 'validates maximum word count for qualifications' do
        course_enrichment.qualifications = Faker::Lorem.sentence(100 + 1)

        expect(course_enrichment).not_to be_valid :publish
        expect(course_enrichment.errors[:qualifications]).to be_present
      end

      it 'validates maximum word count for salary_details' do
        course_enrichment.salary_details = Faker::Lorem.sentence(250 + 1)

        expect(course_enrichment).not_to be_valid :publish
        expect(course_enrichment.errors[:salary_details]).to be_present
      end

      context 'fee based fields' do
        it 'does not validates maximum word count for fee_details' do
          course_enrichment.fee_details = Faker::Lorem.sentence(250 + 1)

          expect(course_enrichment).to be_valid :publish
          expect(course_enrichment.errors[:fee_details]).to be_empty
        end

        it { should_not validate_presence_of(:fee_uk_eu).on(:publish) }
      end
    end
  end

  describe '#unpublish' do
    let(:provider) { create(:provider) }
    let(:course) { create(:course, provider: provider) }
    let(:last_published_timestamp_utc) { Date.new(2017, 1, 1) }
    subject {
      create(:course_enrichment, :published,
             last_published_timestamp_utc: last_published_timestamp_utc,
             course: course,
             provider: provider)
    }

    describe "to initial draft" do
      it 'sets the course to draft' do
        expect { subject.unpublish(initial_draft: true) }.to change { subject.reload.status }
          .from("published")
          .to("draft")
      end

      it 'sets the last_published_timestamp_utc to nil' do
        expect { subject.unpublish(initial_draft: true) }.to change { subject.reload.last_published_timestamp_utc }
          .from(last_published_timestamp_utc)
          .to(nil)
      end
    end

    describe "to subsequent draft" do
      it 'sets the course to draft' do
        expect { subject.unpublish(initial_draft: false) }.to change { subject.reload.status }
          .from("published")
          .to("draft")
      end

      it 'keeps the last_published_timestamp_utc as is' do
        expect { subject.unpublish(initial_draft: false) }.not_to(change { subject.reload.last_published_timestamp_utc })
      end
    end
  end
end
