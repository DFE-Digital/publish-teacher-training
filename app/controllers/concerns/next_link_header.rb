module NextLinkHeader
  extend ActiveSupport::Concern

private

  def set_next_link_header_using_changed_since_or_last_object(last_object,
                                                              params = {})
    next_url_params = {}
    next_url_params[:changed_since] = params[:changed_since]
    next_url_params[:per_page] = params[:per_page]

    if last_object.present?
      next_url_params[:changed_since] =
        incremental_load_timestamp_format last_object.changed_at
    end

    if params[:recruitment_year].nil?
      cycle_year = Settings.current_recruitment_cycle
      response.headers["Link"] = "#{url_for(recruitment_year: cycle_year, params: next_url_params)}; rel=\"next\""
    else
      response.headers["Link"] = "#{url_for(recruitment_year: params[:recruitment_year], params: next_url_params)}; rel=\"next\""
    end
  end

  def incremental_load_timestamp_format(timestamp)
    # When we extract the changed_at from the last provider, format it with
    # sub-second timing information (micro-seconds) so that our incremental
    # fetch can handle many records being updated within the same second.
    #
    # The strftime format '%FT%T.%6NZ' is similar to the ISO8601 standard,
    # (equivalent to %FT%TZ) and adds micro-seconds (%6N).
    timestamp.strftime("%FT%T.%6NZ")
  end
end
