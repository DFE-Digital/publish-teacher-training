# == Schema Information
#
# Table name: course_site
#
#  id                         :integer          not null, primary key
#  applications_accepted_from :date
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

  def publish
    object.publish_before_type_cast
  end

  def course_open_date
    object.applications_accepted_from
  end

  def name
    object.site.location_name
  end

  def recruitment_cycle
    object.recruitment_cycle
  end
end
