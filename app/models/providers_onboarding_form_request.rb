class ProvidersOnboardingFormRequest < ApplicationRecord
  ZENDESK_URL_REGEX = %r{\Ahttps://becomingateacher\.zendesk\.com/.*\z}

  enum :status, %w[pending submitted expired closed rejected onboarded].index_by(&:itself)
  enum :provider_type, %w[university scitt lead_school].index_by(&:itself), validate: { allow_nil: true }

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
    validates :provider_type, presence: true
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
  validates :accredited_provider_number,
            accredited_provider_number_format: { allow_blank: true },
            if: :validate_accredited_provider_number?

  # Rules that apply only when support onboards the request. Run them with valid?(:onboard).
  validate :can_be_onboarded, on: :onboard
  validate :accredited_provider_number_present, on: :onboard

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
    return if provider_type.blank?

    self.class.human_attribute_name(provider_type)
  end

  # Support-facing label. The stored status values stay the same.
  def status_label
    I18n.t(
      "support.providers_onboarding_form_requests.statuses.#{status}",
      default: status.to_s.titleize,
    )
  end

  # Closed is the status stored for requests onboarded before a provider was created here.
  def already_onboarded?
    onboarded? || closed? || provider_id.present?
  end

private

  # Determine if provider-related fields need to be validated based on the submission status or the validation flag
  def run_provider_validations
    submitted? || ActiveModel::Type::Boolean.new.cast(@validate_provider_fields)
  end

  def validate_urn?
    run_provider_validations && lead_school?
  end

  def validate_accredited_provider_number?
    run_provider_validations && accredited_provider?
  end

  def accredited_provider_cannot_be_a_school
    return unless accredited_provider? && lead_school?

    errors.add(:provider_type, :school_is_an_invalid_accredited_provider)
  end

  def can_be_onboarded
    if onboarded? || provider_id.present?
      errors.add(:base, :already_onboarded)
    elsif !submitted?
      errors.add(:base, :not_submitted)
    end
  end

  # The form allows a blank accredited provider number. Onboarding does not.
  def accredited_provider_number_present
    return unless accredited_provider? && accredited_provider_number.blank?

    errors.add(:accredited_provider_number, blank_accredited_provider_number_error)
  end

  def blank_accredited_provider_number_error
    return :university_format if university?
    return :scitt_format if scitt?

    :blank
  end

  # Custom validation to check if the support agent is an admin user
  def support_agent_is_admin
    return if support_agent&.admin?

    errors.add(:support_agent, "must be an admin user")
  end
end
