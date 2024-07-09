# frozen_string_literal: true

class UserForm < Form
  FIELDS = %i[
    first_name
    last_name
    email
    id
  ].freeze

  attr_accessor(*FIELDS)

  def initialize(identifier_model, model, params: {}, provider: nil)
    @provider = provider
    super(identifier_model, model, params:)
  end

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :email, email_address: true
  validate :email_unique_for_provider

  def compute_fields
    model.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end

  private

  def email_unique_for_provider
    errors.add(:email, 'Email address already in use') if @provider&.users&.exists?(email:)
  end
end
