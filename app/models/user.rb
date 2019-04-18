# == Schema Information
#
# Table name: user
#
#  id                     :integer          not null, primary key
#  email                  :text
#  first_name             :text
#  last_name              :text
#  first_login_date_utc   :datetime
#  last_login_date_utc    :datetime
#  sign_in_user_id        :text
#  welcome_email_date_utc :datetime
#  invite_date_utc        :datetime
#  accept_terms_date_utc  :datetime
#  state                  :string
#

class User < ApplicationRecord
  include AASM

  has_and_belongs_to_many :organisations
  has_many :providers, through: :organisations

  validates :email, presence: true

  audited

  aasm column: 'state' do
    state :new, initial: true
    state :transitioned

    event :accept_transition_screen do
      transitions from: :new, to: :transitioned
    end
  end
end
