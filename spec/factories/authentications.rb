FactoryBot.define do
  factory :authentication do
    authenticable { create(:candidate) }
    subject_key { "urn:fdc:gov.uk:2022:FxfvtauQJr_igWuhWM1VammyaszsOfndSyGsgmibajM" }
    traits_for_enum :provider
    provider { :govuk_one_login }
  end
end
