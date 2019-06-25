# == Schema Information
#
# Table name: nctl_organisation
#
#  id              :integer          not null, primary key
#  name            :text
#  nctl_id         :text             not null
#  organisation_id :integer
#  urn             :integer
#  ukprn           :integer
#

FactoryBot.define do
  factory :nctl_organisation, class: NCTLOrganisation do
    name { 'LONDON SCITT' + rand(1000000).to_s }
    sequence(:nctl_id)
  end
end
