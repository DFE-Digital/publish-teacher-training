require "ostruct"

FactoryBot.define do
  factory :importable_ucas_preference, class: OpenStruct do
    transient do
      provider { create :provider }
      organisation { provider.organisations.first }
    end

    INST_CODE { provider.provider_code }
    INST_ID   { organisation.org_id }
    VERSION   { 1 }
    INP_ID    { Random.rand 10000 }
    PRF_ID    { Random.rand 10000 }
    PRT_ID    { Random.rand 10000 }
    PRV_ID    { Random.rand 10000 }

    initialize_with { attributes }

    trait(:type_of_gt12_not_coming) do
      PREF_TYPE  { "Type of GT12 required" }
      PREF_VALUE { "Not coming" }
    end
  end
end
