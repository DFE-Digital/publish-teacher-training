class Authentication < ApplicationRecord
  belongs_to :authenticable, polymorphic: true

  enum :provider, { developer: 0, govuk_one_login: 1 }

  validates :authenticable, :provider, :subject_key, presence: true
  validate :unique_authenticable_with_provider

  def self.provider_map(provider)
    {
      "find-developer" => "developer",
      "one-login" => "govuk_one_login",
    }[provider.to_s]
  end

private

  def unique_authenticable_with_provider
    return if authenticable.nil?

    if self.class.where.not(id:).exists?(authenticable:, provider:)
      errors.add(:authenticable, :unique)
    end
  end
end
