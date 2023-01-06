class UserForm < Form
  FIELDS = %i[
    first_name
    last_name
    email
    id
  ].freeze

  attr_accessor(*FIELDS)

  validates :first_name, presence: true, name: { message: "Enter a valid first name" }
  validates :last_name, presence: true, name: { message: "Enter a valid last name" }
  validates :email, presence: true
  validates :email, email_address: true

  def compute_fields
    model.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end
end
