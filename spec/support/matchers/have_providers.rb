RSpec::Matchers.define :have_providers do |*providers|
  providers = providers.flatten
  def provider_codes(body)
    json = JSON.parse(body)
    json.map { |provider| provider["institution_code"] }
  end

  match do |body|
    if providers
      provider_codes(body) == providers.map(&:provider_code)
    end
  end

  failure_message do |body|
    if providers
      <<~STRING
        expected provider codes #{providers.map(&:provider_code)}
          to be found in body #{provider_codes(body)}
      STRING
    else
      'expected providers to be present, but no providers found'
    end
  end

  failure_message_when_negated do |body|
    if providers
      <<~STRING
          expected provider codes #{providers.map(&:provider_code)}
        not to be found in body #{provider_codes(body)}
      STRING
    else
      "expected no providers to be present, #{provider_codes(body).length} provider(s) found"
    end
  end
end
