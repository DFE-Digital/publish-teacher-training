# frozen_string_literal: true

FactoryBot.define do
  factory :subject_group do
    name { Faker::Name.first_name }
  end
end
