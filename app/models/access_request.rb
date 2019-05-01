# == Schema Information
#
# Table name: access_request
#
#  id               :integer          not null, primary key
#  email_address    :text
#  first_name       :text
#  last_name        :text
#  organisation     :text
#  reason           :text
#  request_date_utc :datetime         not null
#  requester_id     :integer
#  status           :integer          not null
#  requester_email  :text
#

class AccessRequest < ApplicationRecord
  belongs_to :requester, class_name: 'User'

  enum status: %i[
    requested
    approved
    completed
    declined
  ].freeze

  def update_access(access_request, requesting_user)
    requested_user = User.find_by(email: access_request.email_address)
    if requested_user == nil
      access_request.create_requested_user(access_request, requesting_user)
    else
      requested_user.update(organisations: requesting_user.organisations)
    end
  end

  def create_requested_user(access_request, requesting_user)
    User.create(
      email: access_request.email_address,
      first_name: access_request.first_name,
      last_name: access_request.last_name,
      invite_date_utc: Time.now.utc,
      organisations: requesting_user.organisations
    )
  end
end
