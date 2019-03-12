RSpec::Matchers.define :have_providers do |*expected_providers|
  expected_providers = expected_providers.flatten
  def provider_codes(server_response_body)
    json = JSON.parse(server_response_body)
    json.map { |provider| provider["institution_code"] }
  end

  match do |server_response_body|
    if expected_providers.any?
      provider_codes(server_response_body) == expected_providers.map(&:provider_code)
    else
      provider_codes(server_response_body).any? # inverted match logic for "should_not have_providers"
    end
  end

  failure_message do |server_response_body|
    if expected_providers.any?
      <<~STRING
        expected provider codes #{expected_providers.map(&:provider_code)}
        but got #{provider_codes(server_response_body)}
      STRING
    else
      "expected provider codes #{expected_providers.map(&:provider_code)} but no providers found"
    end
  end

  failure_message_when_negated do |server_response_body|
    if expected_providers.any?
      <<~STRING
        didn't expect to find provider codes #{expected_providers.map(&:provider_code)}
        in response. Got: #{provider_codes(server_response_body)}
      STRING
    else
      "expected no providers in response. Got: #{provider_codes(server_response_body)}"
    end
  end
end
