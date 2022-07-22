class User < ApplicationRecord
  include Discard::Model
  include PgSearch::Model
  include RolloverHelper

  has_many :organisation_users

  # dependent destroy because https://stackoverflow.com/questions/34073757/removing-relations-is-not-being-audited-by-audited-gem/34078860#34078860
  has_many :organisations, through: :organisation_users, dependent: :destroy

  has_many :user_notifications, class_name: "UserNotification"

  has_many :providers_via_organisations, through: :organisations, source: :providers

  has_many :user_permissions
  has_many :providers, through: :user_permissions do
    def in_current_cycle
      where(recruitment_cycle: RecruitmentCycle.current)
    end
  end

  has_many :access_requests,
    foreign_key: :requester_id,
    primary_key: :id,
    inverse_of: "requester"

  has_many :interrupt_page_acknowledgements

  scope :admins, -> { where(admin: true) }
  scope :non_admins, -> { where.not(admin: true) }
  scope :active, -> { where.not(accept_terms_date_utc: nil) }
  scope :last_login_since, lambda { |timestamp|
    where("last_login_date_utc > ?", timestamp)
  }
  scope :course_update_subscribers, lambda { |accredited_body_code|
    joins(:user_notifications).merge(UserNotification.course_update_notification_requests(accredited_body_code))
  }
  scope :course_publish_subscribers, lambda { |accredited_body_code|
    joins(:user_notifications).merge(UserNotification.course_publish_notification_requests(accredited_body_code))
  }

  pg_search_scope :search, against: %i[first_name last_name email], using: { tsearch: { prefix: true } }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: /\A.*@.*\z/, message: "must contain @" }, uniqueness: true
  validate :email_is_lowercase

  validates :email, if: :admin?, format: {
    with: /\A.*@(digital\.){0,1}education\.gov\.uk\z/,
    message: "must be an @[digital.]education.gov.uk domain",
  }

  audited

  def to_s
    "#{first_name} #{last_name} <#{email}>"
  end

  def remove_access_to(providers_to_remove)
    providers_to_remove = Array(providers_to_remove)
    self.providers = providers - providers_to_remove

    next_recruitment_cycle_provider_codes = providers_to_remove
        .filter_map { |provider| provider.provider_code if provider.recruitment_cycle.current? }

    if rollover_active? && !RecruitmentCycle.next.nil? && next_recruitment_cycle_provider_codes.any?
      next_cycle_providers = RecruitmentCycle.next_recruitment_cycle.providers.where(provider_code: next_recruitment_cycle_provider_codes)
      self.providers = providers - next_cycle_providers
    end
  end

  def associated_with_accredited_body?
    providers
      .in_current_cycle
      .accredited_body
      .count
      .positive?
  end

  def notifications_configured?
    user_notifications.count.positive?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def accepted_terms?
    accept_terms_date_utc.present?
  end

  def current_rollover_recruitment_acceptance
    current_page_acknowledgement_for("rollover_recruitment")
  end

  def has_multiple_providers?
    providers.count > 1
  end

  def has_multiple_providers_in_current_recruitment_cycle?
    providers.where(recruitment_cycle: RecruitmentCycle.current).count > 1
  end

  def multiple_providers_or_admin?
    admin? || has_multiple_providers_in_current_recruitment_cycle?
  end

private

  def email_is_lowercase
    if email.present? && email.downcase != email
      errors.add(:email, "must be lowercase")
    end
  end

  def current_page_acknowledgement_for(page)
    interrupt_page_acknowledgements
      .includes(:recruitment_cycle).find_by(page:, recruitment_cycle: { year: Settings.current_recruitment_cycle_year })
  end
end
