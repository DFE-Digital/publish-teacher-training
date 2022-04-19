# frozen_string_literal: true

module PageObjects
  class PersonaIndex < PageObjects::Base
    set_url "/personas"

    element :login_as_colin, '[data-disable-with="Login as Colin]'
  end
end
