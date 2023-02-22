# frozen_string_literal: true

module Find
  module ProviderHelper
    def select_provider_options(providers)
      [SelectProvider.new('', 'Select a provider')] + providers.map do |provider|
        value = provider.provider_name
        option = "#{value} (#{provider.provider_code})"
        SelectProvider.new(value, option)
      end
    end

    SelectProvider = Struct.new('SelectProvider', :id, :name)

    def dfe_select_provider_options(providers)
      providers.map do |provider|
        value = provider.provider_name
        option = "#{value} (#{provider.provider_code})"
        DfESelectProvider.new(value, option, provider.synonyms)
      end
    end

    DfESelectProvider = Struct.new('DfeSelectProvider', :id, :name, :synonyms)
  end
end
