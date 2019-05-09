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

  describe 'validation for publish' do
    let(:course_enrichment) do
      create(:course_enrichment, :with_fee_based_course)
    end
    subject { course_enrichment }

    context 'fee based course' do
      it { should_not validate_presence_of(:salary_details).on(:publish) }
      it { should validate_presence_of(:fee_uk_eu).on(:publish) }
      it { should validate_presence_of(:about_course).on(:publish) }
      it { should validate_presence_of(:qualifications).on(:publish) }


      context 'invalid content exceed word count fields' do
        let(:course_enrichment) do
          create(:course_enrichment, :with_fee_based_course,
                 about_course:  Faker::Lorem.sentence(400 + 1),
                 interview_process:  Faker::Lorem.sentence(250 + 1),
                 qualifications:  Faker::Lorem.sentence(100 + 1),
                 how_school_placements_work:  Faker::Lorem.sentence(350 + 1),
                 fee_details:  Faker::Lorem.sentence(250 + 1),
                 salary_details:  Faker::Lorem.sentence(250 + 1))
        end

        subject do
          course_enrichment.valid? :publish
          course_enrichment.errors
        end

        its([:about_course]) { should match_array ['^Reduce the word count for about course'] }
        its([:interview_process]) { should match_array ['^Reduce the word count for interview process'] }
        its([:qualifications]) { should match_array ['^Reduce the word count for qualifications'] }
        its([:how_school_placements_work]) { should match_array ['^Reduce the word count for how school placements work'] }
        its([:fee_details]) { should match_array ['^Reduce the word count for fee details'] }
        its([:salary_details]) { should be_empty }
      end
    end

    context 'salary based course' do
      let(:course_enrichment) do
        create(:course_enrichment, :with_salary_based_course)
      end

      it { should validate_presence_of(:salary_details).on(:publish) }
      it { should validate_presence_of(:about_course).on(:publish) }
      it { should validate_presence_of(:qualifications).on(:publish) }
      it { should_not validate_presence_of(:fee_uk_eu).on(:publish) }

      context 'invalid content exceed word count fields' do
        let(:course_enrichment) do
          create(:course_enrichment, :with_salary_based_course,
                 about_course:  Faker::Lorem.sentence(400 + 1),
                 interview_process:  Faker::Lorem.sentence(250 + 1),
                 qualifications:  Faker::Lorem.sentence(100 + 1),
                 how_school_placements_work:  Faker::Lorem.sentence(350 + 1),
                 fee_details:  Faker::Lorem.sentence(250 + 1),
                 salary_details:  Faker::Lorem.sentence(250 + 1))
        end

        subject do
          course_enrichment.valid? :publish
          course_enrichment.errors
        end

        its([:about_course]) { should match_array ['^Reduce the word count for about course'] }
        its([:interview_process]) { should match_array ['^Reduce the word count for interview process'] }
        its([:qualifications]) { should match_array ['^Reduce the word count for qualifications'] }
        its([:how_school_placements_work]) { should match_array ['^Reduce the word count for how school placements work'] }
        its([:fee_details]) { should be_empty }
        its([:salary_details]) { should match_array ['^Reduce the word count for salary details'] }
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
