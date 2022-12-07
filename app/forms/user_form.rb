class UserForm < Form
  FIELDS = %i[
    first_name
    last_name
    email
    id
  ].freeze

  attr_accessor(*FIELDS)

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :email, email_address: true
  validate :email_is_lowercase

  def compute_fields
    model.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end

  def email_is_lowercase
    if email.present? && email.downcase != email
      errors.add(:email, :lowercase)
    end
  end
end
