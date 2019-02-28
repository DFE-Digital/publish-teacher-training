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
#

require 'rails_helper'

describe ProviderEnrichment, type: :model do
  describe '#touch_provider' do
    let(:provider) { create(:provider) }

    it 'sets changed_at to the current time' do
      Timecop.freeze do
        provider.enrichments.update(email: "test@email")
        expect(provider.changed_at).to eq Time.now.utc
      end
    end

    it 'leaves updated_at unchanged' do
      timestamp = 1.hour.ago
      provider.update updated_at: timestamp
      provider.enrichments.update(email: "test@email")
      expect(provider.updated_at).to eq timestamp
    end
  end
end
