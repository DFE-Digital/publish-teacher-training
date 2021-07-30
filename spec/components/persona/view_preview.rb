# frozen_string_literal: true

module Persona
  class ViewPreview < ViewComponent::Preview
    def login_button
      render(Persona::View.new(email_address: "becomingateacher+admin-integration-tests@digital.education.gov.uk",
                               first_name: "Support agent", last_name: "Colin"))
    end
  end
end
