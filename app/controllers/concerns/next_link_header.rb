module NextLinkHeader
  extend ActiveSupport::Concern

private

  def set_next_link_header_using_changed_since_or_last_object(last_object,
                                                              params = {})
    if last_object.present?
      params[:changed_since] =
        incremental_load_timestamp_format last_object.changed_at
    end

    response.headers['Link'] = "#{url_for(params: params)}; rel=\"next\""
  end

  def incremental_load_timestamp_format(timestamp)
    timestamp.strftime('%FT%T.%6NZ')
  end
end
