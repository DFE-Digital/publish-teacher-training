class ProvidersOnboardingFormRequest < ApplicationRecord
  ZENDESK_URL_REGEX = %r{\Ahttps://becomingateacher\.zendesk\.com/.*\z}

  enum :status, %w[pending submitted expired closed rejected].index_by(&:itself)

  # 3 fields need to be stored once the support team instantiate a form request
  # Every onboarding form request is optionally handled by/assigned a support agent (User)
  belongs_to :support_agent, class_name: "User", optional: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  # Ensure that the support agent is an admin user
  validate :support_agent_is_admin, if: :support_agent_id?
  validates :form_name, presence: true
  validates :zendesk_link, format: {
    with: ZENDESK_URL_REGEX,
    message: "Must be a valid Zendesk URL",
  }, allow_blank: true

  # Virtual flag to trigger provider field validations during form updates
  attr_accessor :validate_provider_fields

  # These fields need to be validated once the form details are submitted by the provider i.e. when the provider clicks 'Continue' on the form page or 'Submit' on the check answers page
  with_options if: :run_provider_validations do
    validates :provider_name, presence: true
    validates :ukprn, ukprn_format: { allow_blank: false }
    validates :accredited_provider, inclusion: { in: [true, false] }
    validates :urn, reference_number_format: { allow_blank: false, minimum: 5, maximum: 6, message: "Provider URN must be 5 or 6 numbers" }
    validates :contact_email_address, email_address: true
    validates :telephone, phone: { allow_blank: false }
    validates :website, presence: true, url: true
    validates :address_line_1, presence: true
    validates :town_or_city, presence: true
    validates :postcode, presence: true, postcode: true
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email_address, email_address: true
  end

  def form_link
    Rails.application.routes.url_helpers.publish_provider_onboarding_url(uuid: uuid)
  end

  # Update the form details with the provided params and trigger provider field validations
  def update_form_details(params)
    assign_attributes(params)
    self.validate_provider_fields = true
    save
  end

  # Submit the onboarding form request and change its status to 'submitted' if valid and not an admin user
  def submit(admin_user)
    self.status = :submitted if pending? && !admin_user
    save
  end

private

  # Determine if provider-related fields need to be validated based on the submission status or the validation flag
  def run_provider_validations
    submitted? || ActiveModel::Type::Boolean.new.cast(@validate_provider_fields)
  end

  # Custom validation to check if the support agent is an admin user
  def support_agent_is_admin
    return if support_agent&.admin?

    errors.add(:support_agent, "must be an admin user")
  end
end
