# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProvidersCache do
  let(:cycle_year) { Find::CycleTimetable.current_year }
  let(:cache_key) { "providers:list:#{cycle_year}" }
  let(:expires_in) { 1.hour }
  let(:providers_cache) { described_class.new(expires_in: expires_in) }

  before do
    Rails.cache.clear
  end

  describe "#providers_list" do
    context "when cache is empty" do
      it "fetches providers from the database and stores them in the cache" do
        create(:provider, provider_name: "Test Provider", provider_code: "TP1", recruitment_cycle: RecruitmentCycle.current)

        first_result = providers_cache.providers_list
        expect(Rails.cache.fetch(cache_key)).to eq(first_result)

        cached_result = providers_cache.providers_list
        expect(cached_result).to eq(first_result)
        expect(Rails.cache.fetch(cache_key)).to eq(first_result)
      end

      it "fetches fresh results when recruitment cycle changes", travel: 15.minutes.before(find_opens(2026)) do
        provider_2025 = create(:provider, provider_name: "Test Provider", provider_code: "TP1", recruitment_cycle: RecruitmentCycle.current)
        provider_2026 = create(:provider, provider_name: "Other Provider", provider_code: "TP2", recruitment_cycle: find_or_create(:recruitment_cycle, :next))

        first_result = providers_cache.providers_list
        expect(Rails.cache.fetch(cache_key)).to eq(first_result)
        expect(first_result).to eq([provider_2025])

        Timecop.travel(30.minutes.from_now)
        expect(Find::CycleTimetable.current_year).to eq(2026)

        new_result = providers_cache.providers_list
        cache_key = "providers:list:2026"
        expect(new_result).not_to eq(first_result)
        expect(Rails.cache.fetch(cache_key)).to eq(new_result)
        expect(new_result).to eq([provider_2026])
      end
    end

    context "when cache is populated" do
      it "returns providers from cache without hitting the database" do
        provider = create(:provider, provider_name: "Cached Provider", provider_code: "CP1", recruitment_cycle: RecruitmentCycle.current)
        cached_data = [ProviderSuggestion.new(id: provider.id, name: "Cached Provider (CP1)", code: "CP1", value: "CP1")]
        Rails.cache.write(cache_key, cached_data, expires_in: expires_in)

        expect(providers_cache.providers_list).to eq(cached_data)
      end
    end
  end
end
