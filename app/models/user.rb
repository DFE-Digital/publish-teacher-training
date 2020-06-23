class User < ApplicationRecord
  include Discard::Model

  has_many :organisation_users

  # dependent destroy because https://stackoverflow.com/questions/34073757/removing-relations-is-not-being-audited-by-audited-gem/34078860#34078860
  has_many :organisations, through: :organisation_users, dependent: :destroy

  has_many :user_notifications, class_name: "UserNotification"

  has_many :providers, through: :organisations

  has_many :access_requests,
           foreign_key: :requester_id,
           primary_key: :id,
           inverse_of: "requester"

  scope :admins, -> { where(admin: true) }
  scope :non_admins, -> { where.not(admin: true) }
  scope :active, -> { where.not(accept_terms_date_utc: nil) }
  scope :last_login_since, ->(timestamp) do
    where("last_login_date_utc > ?", timestamp)
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

  def to_s
    "#{first_name} #{last_name} <#{email}>"
  end

  # accepts array or single organisation
  def remove_access_to(organisations_to_remove)
    self.organisations = self.organisations - Array(organisations_to_remove)
  end

  def associated_with_accredited_body?
    providers
      .in_current_cycle
      .accredited_body
      .count
      .positive?
  end

private

  def email_is_lowercase
    if email.present? && email.downcase != email
      errors.add(:email, "must be lowercase")
    end
  end
end
