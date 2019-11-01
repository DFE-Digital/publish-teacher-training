# == Schema Information
#
# Table name: user
#
#  accept_terms_date_utc  :datetime
#  admin                  :boolean          default(FALSE)
#  email                  :text
#  first_login_date_utc   :datetime
#  first_name             :text
#  id                     :integer          not null, primary key
#  invite_date_utc        :datetime
#  last_login_date_utc    :datetime
#  last_name              :text
#  sign_in_user_id        :text
#  state                  :string           not null
#  welcome_email_date_utc :datetime
#
# Indexes
#
#  IX_user_email  (email) UNIQUE
#

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    first_login_date_utc { Faker::Time.backward(days: 1).utc }
    welcome_email_date_utc { Faker::Time.backward(days: 1).utc }
    accept_terms_date_utc { Faker::Time.backward(days: 1).utc }
    sign_in_user_id { SecureRandom.uuid }

    trait :admin do
      email { "#{Faker::Internet.username}@#{['digital.education.gov.uk', 'education.gov.uk'].sample}" }
    end

    trait :with_organisation do
      organisations { [create(:organisation)] }
    end

    trait :with_provider do
      organisations { [create(:organisation, providers: [create(:provider)])] }
    end

    trait :inactive do
      accept_terms_date_utc { nil }
    end

    trait :is_admin do
      admin { true }
    end
  end
end
