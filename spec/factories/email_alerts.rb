FactoryBot.define do
  factory :email_alert, class: "Candidate::EmailAlert" do
    association :candidate
    sequence(:subjects) { |n| [sprintf("%02d", n)] }
    search_attributes { {} }
  end
end
