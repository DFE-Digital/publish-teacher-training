# == Schema Information
#
# Table name: user
#
#  accept_terms_date_utc  :datetime
#  admin                  :boolean          default(FALSE)
#  email                  :text
#  first_login_date_utc   :datetime
#  first_name             :text
#  id                     :integer          not null, primary key
#  invite_date_utc        :datetime
#  last_login_date_utc    :datetime
#  last_name              :text
#  sign_in_user_id        :text
#  state                  :string           not null
#  welcome_email_date_utc :datetime
#
# Indexes
#
#  IX_user_email  (email) UNIQUE
#

class User < ApplicationRecord
  include AASM

  has_many :organisation_users

  # dependent destroy because https://stackoverflow.com/questions/34073757/removing-relations-is-not-being-audited-by-audited-gem/34078860#34078860
  has_many :organisations, through: :organisation_users, dependent: :destroy

  has_many :user_notifications

  has_many :providers, through: :organisations

  has_many :access_requests,
           foreign_key: :requester_id,
           primary_key: :id,
           inverse_of: "requester"

  scope :admins, -> { where(admin: true) }
  scope :non_admins, -> { where.not(admin: true) }
  scope :active, -> { where.not(accept_terms_date_utc: nil) }
  scope :notifiable_users, ->(provider_code) do
    joins(:user_notifications).merge(
      UserNotification.course_update_notification_requests(provider_code),
    )
  end

  validates :email, presence: true, format: { with: /\A.*@.*\z/, message: "must contain @" }
  validate :email_is_lowercase
  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :email, if: :admin?, format: {
    with: /\A.*@(digital\.){0,1}education\.gov\.uk\z/,
    message: "must be an @[digital.]education.gov.uk domain",
  }

  audited

  aasm column: "state" do
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
