class SiteStatusSerializer < ActiveModel::Serializer
  attributes :campus_code, :name, :vac_status, :publish, :status, :course_open_date

  def campus_code
    object.site.code
  end

  # rubocop:disable Style/DateTime
  def course_open_date
    # TODO applications_accepted_from should be a timestamp, not a string
    DateTime.parse(object.applications_accepted_from).iso8601 if object.applications_accepted_from
  end
  # rubocop:enable Style/DateTime

  def name
    object.site.location_name
  end
end
