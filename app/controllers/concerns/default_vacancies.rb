# frozen_string_literal: true

module DefaultVacancies
  def default_vacancies
    form_params['has_vacancies'].nil? ? 'true' : form_params['has_vacancies']
  end
end
