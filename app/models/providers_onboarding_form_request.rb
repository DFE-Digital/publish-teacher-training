class ProvidersOnboardingFormRequest < ApplicationRecord
  ZENDESK_URL_REGEX = %r{\Ahttps://becomingateacher\.zendesk\.com/.*\z}
  PROVIDER_TYPES = {
    "university" => "Higher education institution (HEI)",
    "scitt" => "School centred initial teacher training (SCITT)",
    "lead_school" => "School",
  }.freeze

  enum :status, %w[pending submitted expired closed rejected onboarded].index_by(&:itself)

  # 3 fields need to be stored once the support team instantiate a form request
  # Every onboarding form request is optionally handled by/assigned a support agent (User)
  belongs_to :support_agent, class_name: "User", optional: true
  belongs_to :provider, optional: true
  validates :provider, presence: true, if: :onboarded?
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
    validates :provider_type, presence: true, inclusion: { in: PROVIDER_TYPES.keys }
    validates :contact_email_address, email_address: true
    validates :telephone, phone: { allow_blank: false }
    validates :website, presence: true, url: true
    validates :address_line_1, presence: true
    validates :town_or_city, presence: true
    validates :postcode, presence: true, postcode: true
    validates :email_address, email_address: true
    validates :first_name, presence: true
    validates :last_name, presence: true
  end

  validates :urn,
            reference_number_format: { allow_blank: false, minimum: 5, maximum: 6, message: "Provider URN must be 5 or 6 numbers" },
            if: :validate_urn?
  validate :accredited_provider_cannot_be_a_school, if: :run_provider_validations
  validate :accredited_provider_number_format, if: :run_provider_validations

  def form_link
    Rails.application.routes.url_helpers.publish_provider_onboarding_url(uuid: uuid)
  end

  # Update the form details with the provided params and trigger provider field validations
  def update_form_details(params)
    assign_attributes(params)
    self.validate_provider_fields = true
    save
  end

  # Confirm the onboarding form and mark a pending request as submitted
  def submit
    self.status = :submitted if pending?
    save
  end

  def provider_type_label
    PROVIDER_TYPES[provider_type]
  end

  def lead_school?
    provider_type == "lead_school"
  end

  def university?
    provider_type == "university"
  end

  def scitt?
    provider_type == "scitt"
  end

private

  # Determine if provider-related fields need to be validated based on the submission status or the validation flag
  def run_provider_validations
    submitted? || ActiveModel::Type::Boolean.new.cast(@validate_provider_fields)
  end

  def validate_urn?
    run_provider_validations && lead_school?
  end

  def accredited_provider_cannot_be_a_school
    return unless accredited_provider? && lead_school?

    errors.add(:provider_type, :school_is_an_invalid_accredited_provider)
  end

  def accredited_provider_number_format
    return unless accredited_provider?
    return if accredited_provider_number.blank?

    if university?
      errors.add(:accredited_provider_number, :university_format) unless accredited_provider_number.match?(/\A1\d{3}\z/)
    elsif scitt?
      errors.add(:accredited_provider_number, :scitt_format) unless accredited_provider_number.match?(/\A5\d{3}\z/)
    else
      errors.add(:accredited_provider_number, :invalid) unless accredited_provider_number.match?(/\A[15]\d{3}\z/)
    end
  end

  # Custom validation to check if the support agent is an admin user
  def support_agent_is_admin
    return if support_agent&.admin?

    errors.add(:support_agent, "must be an admin user")
  end
end
