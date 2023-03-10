# frozen_string_literal: true

FactoryBot.define do
  factory :gias_school do
    urn { '100000' }
    name { 'school name' }
    address1 { 'the address' }
    town { 'anytown' }
    postcode { 'postcode' }
  end
end
