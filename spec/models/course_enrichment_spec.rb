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

      its(:status) { should eq 'published' }
      its(:updated_at) { should be_within(1.second).of Time.now.utc }
      its(:last_published_timestamp_utc) { should be_within(1.second).of Time.now.utc }
      its(:updated_by_user_id) { should eq user.id }
    end

    context 'when the enrichment is a subsequent draft' do
      subject { create(:course_enrichment, :subsequent_draft, created_at: 1.day.ago, updated_at: 20.minutes.ago) }

      before do
        subject.publish(user)
      end

      its(:status) { should eq 'published' }
      its(:updated_at) { should be_within(1.second).of Time.now.utc }
      its(:last_published_timestamp_utc) { should be_within(1.second).of Time.now.utc }
      its(:updated_by_user_id) { should eq user.id }
    end
  end
end
