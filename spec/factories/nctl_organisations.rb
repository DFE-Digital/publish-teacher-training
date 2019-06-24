FactoryBot.define do
  factory :nctl_organisation, class: NCTLOrganisation do
    name { 'LONDON SCITT' + rand(1000000).to_s }
    sequence(:nctl_id)
  end
end
