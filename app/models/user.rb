# == Schema Information
#
# Table name: user
#
#  id                     :integer          not null, primary key
#  email                  :text
#  first_name             :text
#  last_name              :text
#  first_login_date_utc   :datetime
#  last_login_date_utc    :datetime
#  sign_in_user_id        :text
#  welcome_email_date_utc :datetime
#  invite_date_utc        :datetime
#  accept_terms_date_utc  :datetime
#  state                  :string           not null
#

class User < ApplicationRecord
  include AASM

  DFE_EMAIL_PATTERN = '@(digital\.){0,1}education\.gov\.uk$'.freeze

  has_and_belongs_to_many :organisations
  has_many :providers, through: :organisations
  has_many :access_requests,
           foreign_key: :requester_id,
           primary_key: :id,
           inverse_of: 'requester'

  scope :admins, -> { where('email ~ ?', DFE_EMAIL_PATTERN) }
  scope :non_admins, -> { where.not('email ~ ?', DFE_EMAIL_PATTERN) }
  scope :active, -> { where.not(accept_terms_date_utc: nil) }

  validates :email, presence: true, format: { with: /@/, message: "must contain @" }
  validate :email_is_lowercase

  audited

  aasm column: 'state' do
    state :new, initial: true
    state :transitioned
    state :rolled_over

    event :accept_transition_screen do
      transitions from: :new, to: :transitioned
    end

    event :accept_rollover_screen do
      transitions from: :transitioned, to: :rolled_over
    end
  end

  def admin?
    email.match?(%r{#{DFE_EMAIL_PATTERN}})
  end

  def to_s
    "#{first_name} #{last_name} <#{email}>"
  end

  # accepts array or single organisation
  def remove_access_to(organisations_to_remove)
    self.organisations = self.organisations - Array(organisations_to_remove)
  end

private

  def email_is_lowercase
    if email.present? && email.downcase != email
      errors.add(:email, "must be lowercase")
    end
  end
end
