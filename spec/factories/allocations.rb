# == Schema Information
#
# Table name: allocation
#
#  accredited_body_code :text
#  accredited_body_id   :bigint
#  created_at           :datetime         not null
#  id                   :bigint           not null, primary key
#  number_of_places     :integer
#  provider_code        :text
#  provider_id          :bigint
#  recruitment_cycle_id :integer
#  request_type         :integer          default("initial")
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_allocation_on_accredited_body_id  (accredited_body_id)
#  index_allocation_on_provider_id         (provider_id)
#  index_allocation_on_request_type        (request_type)
#
FactoryBot.define do
  factory :allocation do
    association :accredited_body, factory: %i(provider accredited_body)
    association :provider
    number_of_places { 0 }
  end
end
