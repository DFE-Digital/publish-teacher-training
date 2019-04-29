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

    context 'publish context' do
      let(:course_enrichment) { create(:course_enrichment) }

      subject! { course_enrichment.valid? :publish }


      describe 'validation' do
        it { should be true }

        context 'exceeded word count' do
          let(:course_enrichment) {
            create(:course_enrichment,
             about_course: (%w[word] * 400).join(' ') + " exceeeded",
             interview_process: (%w[word] * 250).join(' ') + " exceeeded",
             how_school_placements_work: (%w[word] * 350).join(' ') + " exceeeded",

             fee_details: (%w[word] * 250).join(' ') + " exceeeded",
             salary_details: (%w[word] * 250).join(' ') + " exceeeded",
             financial_support: (%w[word] * 250).join(' ') + " exceeeded")
          }

          it { should be false }
          it 'add errors ' do
            expect(course_enrichment.errors[:about_course]).to match_array ['it exceeded max words count']
            expect(course_enrichment.errors[:interview_process]).to match_array ['it exceeded max words count']
            expect(course_enrichment.errors[:how_school_placements_work]).to match_array ['it exceeded max words count']
            expect(course_enrichment.errors[:fee_details]).to match_array ['it exceeded max words count']
            expect(course_enrichment.errors[:salary_details]).to match_array ['it exceeded max words count']
            expect(course_enrichment.errors[:financial_support]).to match_array ['it exceeded max words count']
          end
        end

        context 'no presence' do
          ['', nil].each do |presence|
            let(:course_enrichment) {
              create(:course_enrichment,
                fee_uk_eu: presence,
                salary_details: presence)
            }
            it { should be false }
            it 'add errors ' do
              expect(course_enrichment.errors[:salary_details]).to match_array ["can't be blank"]
              expect(course_enrichment.errors[:fee_uk_eu]).to match_array ["is not a number", "can't be blank"]
            end
          end
        end
        context 'numericality' do
          ['', -1, 100001, nil, 'one'].each do |numericality|
            let(:course_enrichment) {
              create(:course_enrichment,
                fee_international: numericality,
                fee_uk_eu: numericality)
            }
            it { should be false }

            it 'add errors ' do
              expect(course_enrichment.errors[:fee_international]).to match_array ["is not a number"]
              expect(course_enrichment.errors[:fee_uk_eu]).to match_array ["is not a number"]
            end
          end
        end
      end
    end
  end
end
