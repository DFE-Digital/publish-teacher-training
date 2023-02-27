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

    def dfe_autocomplete_options(records, synonyms_fields: [:synonyms], append: false, boost: 1.5)
      records.sort_by(&:name).map do |record|
        data = {
          'data-synonyms' => dfe_autocomplete_synonyms_for(record, synonyms_fields).flatten.join('|'),
          'data-boost' => boost
        }

        append_data = record.send(append) if append.present?
        data['data-append'] = append_data && tag.strong("(#{append_data})")

        name = record.name
        value = record.try(:value).presence || name

        [name, value, data]
      end.unshift([nil, nil, nil])
    end

    private

    def dfe_autocomplete_synonyms_for(record, synonyms_fields)
      synonyms = []

      synonyms_fields.each do |synonym_field|
        synonyms << record.send(synonym_field) if record.respond_to?(synonym_field)
      end

      synonyms
    end
  end
end
