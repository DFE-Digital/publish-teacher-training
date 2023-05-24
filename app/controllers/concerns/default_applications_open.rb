# frozen_string_literal: true

module DefaultApplicationsOpen
  def default_applications_open
    form_params['applications_open'].nil? ? 'true' : form_params['applications_open']
  end
end
