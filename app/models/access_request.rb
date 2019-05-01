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

  alias_method :approve, :completed!

  audited
end
