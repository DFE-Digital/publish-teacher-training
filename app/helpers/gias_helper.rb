module GIASHelper
  def matches_grouped_by_provider_for_establishment(establishment)
    providers = {}

    establishment.providers_matched_by_name.each do |provider|
      providers[provider] ||= []
      providers[provider] << "establishment name matches provider"
    end

    establishment.sites_matched_by_name.each do |site|
      providers[site.provider] ||= []
      providers[site.provider] << "establishment name matches site: #{site.location_name}"
    end

    establishment.providers_matched_by_postcode.each do |provider|
      providers[provider] ||= []
      providers[provider] << "establishment postcode (#{establishment.postcode}) matches provider"
    end

    establishment.sites_matched_by_postcode.each do |site|
      providers[site.provider] ||= []
      providers[site.provider] << "establishment postcode (#{establishment.postcode}) matches site: #{site.location_name}"
    end

    providers
  end

  def matches_grouped_by_establishment_for_provider(provider)
    establishments = {}

    provider.establishments_matched_by_name.each do |establishment|
      establishments[establishment] ||= []
      establishments[establishment] << "provider's name matches"
    end

    provider.sites_with_establishments_matched_by_name.distinct.each do |site|
      site.establishments_matched_by_name.each do |establishment|
        establishments[establishment] ||= []
        establishments[establishment] << "site's name matches: #{site.location_name}"
      end
    end

    provider.establishments_matched_by_postcode.each do |establishment|
      establishments[establishment] ||= []
      establishments[establishment] << "provider's postcode (#{establishment.postcode}) matches"
    end

    provider.sites_with_establishments_matched_by_postcode.distinct.each do |site|
      site.establishments_matched_by_postcode.each do |establishment|
        establishments[establishment] ||= []
        establishments[establishment] << "site's postcode (#{establishment.postcode}) matches: #{site.location_name}"
      end
    end

    establishments
  end

private

  def provider_key(provider)
    "#{provider.provider_name} - #{provider.provider_code}"
  end
end
