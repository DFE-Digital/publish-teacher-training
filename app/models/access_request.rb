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

  def add_additional_attributes(requester_email)
    self.update(requester: User.find_by(email: requester_email),
                request_date_utc: Time.now.utc,
                status: :requested)
  end

  alias_method :approve, :completed!

  validates :first_name, :last_name, :email_address,
            :reason, :requester_email,
            presence: true

  audited
end
