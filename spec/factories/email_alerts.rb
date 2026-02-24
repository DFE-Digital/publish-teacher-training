FactoryBot.define do
  factory :email_alert, class: "Candidate::EmailAlert" do
    association :candidate
    subjects { [] }
    search_attributes { {} }
  end
end
