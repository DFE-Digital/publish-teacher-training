# frozen_string_literal: true

class PersonaPreview < ViewComponent::Preview
  def login_button
    render(Persona.new(email_address: "becomingateacher+admin-integration-tests@digital.education.gov.uk",
      first_name: "Support agent", last_name: "Colin"))
  end
end
