# frozen_string_literal: true

module Find
  module ProviderHelper
    def provider_autocomplete_options(providers)
      providers.sort_by(&:provider_name).map do |provider|
        data = {
          'data-synonyms' => provider.synonyms.join('|'),
          'data-boost' => 1.5
        }

        value = provider.provider_name.strip
        name = "#{value} (#{provider.provider_code})"

        [name, value, data]
      end.unshift(Array.new(3))
    end
  end
end
