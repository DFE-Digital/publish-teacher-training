# == Schema Information
#
# Table name: access_request
#
#  discarded_at     :datetime
#  email_address    :text
#  first_name       :text
#  id               :integer          not null, primary key
#  last_name        :text
#  organisation     :text
#  reason           :text
#  request_date_utc :datetime         not null
#  requester_email  :text
#  requester_id     :integer
#  status           :integer          not null
#
# Indexes
#
#  IX_access_request_requester_id        (requester_id)
#  index_access_request_on_discarded_at  (discarded_at)
#

class AccessRequest < ApplicationRecord
  include Discard::Model
  default_scope -> { kept }

  belongs_to :requester, class_name: "User"

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

  def add_additonal_attributes(requester_email)
    self.update(requester: User.find_by(email: requester_email),
                request_date_utc: Time.now.utc,
                status: :requested)
  end

  alias_method :approve, :completed!

  validates :first_name, :last_name, :email_address,
            :organisation, :reason, :requester_email,
            presence: true

  audited
end
