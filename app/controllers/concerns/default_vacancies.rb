module DefaultVacancies
  def default_vacancies
    form_params["has_vacancies"].nil? ? "true" : form_params["has_vacancies"]
  end
end
