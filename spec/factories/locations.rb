# frozen_string_literal: true

FactoryBot.define do
  factory :location, class: Struct.new(:latitude, :longitude, keyword_init: true) do
    latitude { 0.0 }
    longitude { 0.0 }

    trait :bristol do
      latitude { 51.4545 }
      longitude { -2.5879 }
    end

    trait :cambridge do
      latitude { 52.2053 }
      longitude { 0.1218 }
    end

    trait :canary_wharf do
      latitude { 51.5045 }
      longitude { -0.0243 }
    end

    trait :cardiff do
      latitude { 51.4816 }
      longitude { -3.1791 }
    end

    trait :cornwall do
      latitude { 50.5036299 }
      longitude { -4.6524982 }
    end

    trait :crawley do
      latitude { 51.1091 }
      longitude { -0.1872 }
    end

    trait :edinburgh do
      latitude { 55.9533 }
      longitude { -3.1883 }
    end

    trait :farnborough do
      latitude { 51.2903 }
      longitude { -0.7501 }
    end

    trait :guildford do
      latitude { 51.2362 }
      longitude { -0.5704 }
    end

    trait :lewisham do
      latitude { 51.4539 }
      longitude { -0.016 }
    end

    trait :london do
      latitude { 51.5074 }
      longitude { -0.1278 }
    end

    trait :manchester do
      latitude { 53.4808 }
      longitude { -2.2426 }
    end

    trait :norwich do
      latitude { 52.6309 }
      longitude { 1.2974 }
    end

    trait :oxford do
      latitude { 51.7548 }
      longitude { -1.2544 }
    end

    trait :reading do
      latitude { 51.4543 }
      longitude { -0.9781 }
    end

    trait :romford do
      latitude { 51.5807 }
      longitude { 0.185 }
    end

    trait :watford do
      latitude { 51.6553 }
      longitude { -0.3960 }
    end

    trait :wimbledon do
      latitude { 51.4230 }
      longitude { -0.2195 }
    end

    trait :woking do
      latitude { 51.3200 }
      longitude { -0.5582 }
    end
  end
end
