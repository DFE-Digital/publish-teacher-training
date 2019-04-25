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
#  state                  :string           not null
#

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    accept_terms_date_utc { Faker::Time.backward(1).utc }
    sign_in_user_id { SecureRandom.uuid }

    trait :opted_in do
      organisations { [create(:organisation, providers: [create(:provider, opted_in: true)])] }
    end
  end
end
