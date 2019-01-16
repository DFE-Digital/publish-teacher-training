# == Schema Information
#
# Table name: course_site
#
#  id                         :integer          not null, primary key
#  applications_accepted_from :text
#  course_id                  :integer
#  publish                    :text
#  site_id                    :integer
#  status                     :text
#  vac_status                 :text
#

class SiteStatusSerializer < ActiveModel::Serializer
  attributes :campus_code, :name, :vac_status, :publish, :status, :course_open_date, :recruitment_cycle

  def campus_code
    object.site.code
  end

  def vac_status
    object.vac_status_before_type_cast
  end

  def status
    object.status_before_type_cast
  end

  # rubocop:disable Style/DateTime
  def course_open_date
    # TODO applications_accepted_from should be a timestamp, not a string
    DateTime.parse(object.applications_accepted_from).iso8601 if object.applications_accepted_from.present?
  end
  # rubocop:enable Style/DateTime

  def name
    object.site.location_name
  end

  # TODO: make recruitment cycle dynamic
  def recruitment_cycle
    "2019"
  end
end
