module NextLinkHeader
  extend ActiveSupport::Concern
  include TimeFormat

private

  def set_next_link_header_using_changed_since_or_last_object(last_object,
                                                              params = {})
    next_url_params = {}
    next_url_params[:changed_since] = params[:changed_since]
    next_url_params[:per_page] = params[:per_page]

    if last_object.present?
      next_url_params[:changed_since] = precise_time(last_object.changed_at)
    end

    if params[:recruitment_year].nil?
      cycle_year = Settings.current_recruitment_cycle_year
      response.headers["Link"] = "#{url_for(recruitment_year: cycle_year, params: next_url_params)}; rel=\"next\""
    else
      response.headers["Link"] = "#{url_for(recruitment_year: params[:recruitment_year], params: next_url_params)}; rel=\"next\""
    end
  end
end
