FactoryBot.define do
  factory :authentication do
    authenticable { create(:candidate) }
    sub { "urn:fdc:gov.uk:2022:FxfvtauQJr_igWuhWM1VammyaszsOfndSyGsgmibajM" }
    iss { "https://oidc.integration.account.gov.uk/" }
  end
end
