class ProvidersOnboardingFormRequest < ApplicationRecord
  enum :status, %w[pending submitted expired closed rejected].index_by(&:itself)

  # 3 fields need to be stored once the support team instantiate a form request
  # Every onboarding form request is optionally handled by/assigned a support agent (User)
  belongs_to :support_agent, class_name: "User", optional: true

  validates :uuid, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  # Ensure that the support agent is an admin user
  validate :support_agent_is_admin, if: :support_agent_id?
  validates :form_name, presence: true
  validates :form_link, presence: true, on: :update

  # These fields need to be validated once the form details are submitted by the provider i.e. status changes to 'submitted'
  with_options if: :submitted? do
    validates :first_name, :last_name,
              :provider_name, :address_line_1, :town_or_city, presence: true

    validates :email_address, :contact_email_address, email_address: true
    validates :postcode, presence: true, postcode: true
    validates :telephone, phone: true
    validates :website, presence: true, url: true
    validates :accredited_provider, inclusion: { in: [true, false] }
    validates :ukprn, ukprn_format: { allow_blank: false }
    validates :urn, reference_number_format: { allow_blank: false, minimum: 5, maximum: 6, message: "Provider URN must be 5 or 6 numbers" }
  end

private

  # Custom validation to check if the support agent is an admin user
  def support_agent_is_admin
    return if support_agent&.admin?

    errors.add(:support_agent, "must be an admin user")
  end
end
