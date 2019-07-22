# == Schema Information
#
# Table name: provider_enrichment
#
#  id                 :integer          not null
#  provider_code      :text             not null, primary key
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
      binding.pry
      expect(ProviderEnrichment.latest_created_at.first).to eq new_enrichment
      expect(ProviderEnrichment.latest_created_at.last).to eq old_enrichment
    end
  end
end
