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
  after_commit :update_status_to_requested, on: :create

  enum status: %i[
    requested
    approved
    completed
    declined
  ].freeze

  scope :by_request_date, -> { order(request_date_utc: :asc) }

  def recipient
    User.new(first_name: first_name, last_name: last_name, email: email_address)
  end

  alias_method :approve, :completed!

  audited

private

  def update_status_to_requested
    self.requester        = User.find_by(email: self.requester_email)
    self.request_date_utc = Time.now.utc
    self.status           = :requested
  end
end
