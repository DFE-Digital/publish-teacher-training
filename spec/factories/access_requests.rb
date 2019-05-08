# == Schema Information
#
# Table name: access_request
#
#  id               :integer          not null, primary key
#  email_address    :text
#  first_name       :text
#  last_name        :text
#  organisation     :text
#  reason           :text
#  request_date_utc :datetime         not null
#  requester_id     :integer
#  status           :integer          not null
#  requester_email  :text
#

FactoryBot.define do
  factory :access_request do
    requester { build(:user, :with_organisation) }
    status { :requested }
    request_date_utc { Time.now.utc }
    email_address { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    organisation { requester.organisations.first }
    reason { Faker::Lorem.sentence.to_s }
    requester_email { requester.email }
  end

  trait :requested do
    status { :requested }
  end

  trait :approved do
    status { :approved }
  end

  trait :completed do
    status { :completed }
  end

  trait :declined do
    status { :declined }
  end
end
