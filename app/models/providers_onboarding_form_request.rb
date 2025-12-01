class ProvidersOnboardingFormRequest < ApplicationRecord
  enum :status, %w[pending submitted expired closed rejected].index_by(&:itself)

  # Every onboarding form request is optionally handled by/assigned a support agent (User)
  belongs_to :support_agent, class_name: "User", optional: true

  validates :uuid, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: statuses.keys }

  validates :form_name, :email_address, :first_name, :last_name,
            :organisation_name, :address_line_1, :town_or_city,
            :postcode, :phone_number, :contact_email_address, :organisation_website,
            :accredited_provider, :ukprn, :urn, presence: true

  # Ensure that the support agent is an admin user
  validate :support_agent_is_admin, if: :support_agent_id?

private

  # Custom validation to check if the support agent is an admin user
  def support_agent_is_admin
    return if support_agent&.admin?

    errors.add(:support_agent, "must be an admin user")
  end
end
