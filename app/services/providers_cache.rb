# frozen_string_literal: true

class ProvidersCache
  attr_reader :expires_in

  def initialize(expires_in: 1.hour)
    @expires_in = expires_in
  end

  def providers_list
    Rails.cache.fetch("providers:list:#{Find::CycleTimetable.current_year}", expires_in: expires_in) do
      RecruitmentCycle.current.providers
                      .by_name_ascending
                      .select(:id, :provider_name, :provider_code)
                      .map do |provider|
        ProviderSuggestion.new(
          id: provider.id,
          name: provider.name_and_code,
          code: provider.provider_code,
          value: provider.provider_code,
        )
      end
    end
  end
end
