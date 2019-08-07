# == Schema Information
#
# Table name: provider_enrichment
#
#  id                 :integer          not null, primary key
#  provider_code      :text             not null
#  json_data          :jsonb
#  updated_by_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by_user_id :integer
#  last_published_at  :datetime
#  status             :integer          default("draft"), not null
#  provider_id        :integer          not null
#

require 'rails_helper'

describe ProviderEnrichment, type: :model do
  describe 'associations' do
    it { should belong_to(:provider) }
  end

  describe '#has_been_published_before?' do
    context 'when the enrichment is an initial draft' do
      subject { create(:provider_enrichment, :initial_draft) }
      it { should_not have_been_published_before }
    end

    context 'when the enrichment is published' do
      subject { create(:provider_enrichment, :published) }
      it { should have_been_published_before }
    end

    context 'when the enrichment is a subsequent draft' do
      subject { create(:provider_enrichment, :subsequent_draft) }
      it { should have_been_published_before }
    end
  end

  describe '.latest_first' do
    let!(:old_enrichment) do
      create(:provider_enrichment, :published, created_at: Date.yesterday)
    end
    let!(:new_enrichment) { create(:provider_enrichment, :published) }

    it 'returns the new enrichment first' do
      expect(ProviderEnrichment.latest_created_at.first).to eq new_enrichment
      expect(ProviderEnrichment.latest_created_at.last).to eq old_enrichment
    end
  end

  describe '#publish' do
    let(:user) { create :user }
    let!(:provider_enrichment) { create(:provider_enrichment, :initial_draft) }

    it 'sets the status to published' do
      publish_time = Time.parse("2019-07-30")
      Timecop.freeze(publish_time) do
        provider_enrichment.publish(user)
        provider_enrichment.reload
        expect(provider_enrichment.status).to eq('published')
        expect(provider_enrichment.last_published_at).to eq(publish_time.utc)
        expect(provider_enrichment.updated_by_user_id).to eq(user.id)
      end
    end
  end

  describe 'before_create hook' do
    # Note: provider_code is only here to support c# counterpart, until provide_code is removed from database
    let(:provider) { build(:provider) }
    let(:existing_provider_code) { nil }
    let(:enrichment) { create(:provider_enrichment, provider: provider, provider_code: existing_provider_code) }
    subject { enrichment }

    context 'when provider_code is blank' do
      its(:provider_code) { should eq(provider.provider_code) }
    end

    context 'when provider code is already set' do
      let(:existing_provider_code) { "XX4" }

      its(:provider_code) { should eq(existing_provider_code) }
    end
  end
end
