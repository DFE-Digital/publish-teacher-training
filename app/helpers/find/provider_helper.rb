module Find
  module ProviderHelper
    def select_provider_options(providers)
      [SelectProvider.new("", "Select a provider")] + providers.map do |provider|
        value = "#{provider.provider_name}"
        option = "#{provider.provider_name} (#{provider.provider_code})"
        SelectProvider.new(value, option)
      end
    end

    SelectProvider = Struct.new("SelectProvider", :id, :name)
  end
end
