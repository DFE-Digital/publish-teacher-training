module NextLinkHeader
  extend ActiveSupport::Concern

private

  def next_link_header(from_key_string, last_object, next_object, changed_since, per_page)
    response.headers['Link'] = if last_object
                                 next_object_timestamp = (next_object ? next_object.updated_at : last_object.updated_at + 1.second).utc.iso8601
                                 header_content(from_key_string, next_object_timestamp, last_object.id, per_page)
                               else
                                 header_content(from_key_string, changed_since, "", per_page)
                               end
  end

  def header_content(from_key_string, changed_since, from_object_id, per_page)
    current_url = request.base_url + request.path
    "#{current_url}?changed_since=#{changed_since}&#{from_key_string}=#{from_object_id}&per_page=#{per_page}; rel=\"next\""
  end
end
