# frozen_string_literal: true

class APIKey < ApplicationRecord
  MAXIMUM_ACTIVE = 5
  SECRET_PREFIX = APIKeySecret::PREFIX
  DISPLAY_PREFIX_LENGTH = 12

  self.filter_attributes += %i[email key_digest name]

  audited only: %i[prefix revoked_at], associated_with: :user

  belongs_to :user, foreign_key: :email, primary_key: :email, inverse_of: :api_keys, optional: true

  attr_readonly :email

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, email_address: { allow_blank: true }, on: :create
  validates :name, presence: true
  validate :active_limit_not_reached, on: :create
  validates :submission_token, uniqueness: true, allow_nil: true, on: :create

  scope :active, -> { where(revoked_at: nil) }

  attr_accessor :secret

  def self.digest(secret) = Digest::SHA256.hexdigest(secret.to_s)

  def self.find_active_by_secret(secret)
    active.find_by(key_digest: digest(secret))
  end

  def self.search(query)
    return all if query.blank?

    pattern = "%#{sanitize_sql_like(query.strip)}%"
    where("name ILIKE :pattern OR email ILIKE :pattern", pattern:)
  end

  def self.lock_email(email)
    key = digest(normalize_value_for(:email, email))
    connection.execute(sanitize_sql(["SELECT pg_advisory_xact_lock(hashtextextended(?, 0))", key]))
  end

  def revoke!
    touch(:revoked_at) unless revoked_at?
  end

private

  def active_limit_not_reached
    return if self.class.active.where(email:).count < MAXIMUM_ACTIVE

    errors.add(:email, :limit_reached, count: MAXIMUM_ACTIVE)
  end
end
