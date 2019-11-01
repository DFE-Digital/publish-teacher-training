# == Schema Information
#
# Table name: organisation
#
#  id     :integer          not null, primary key
#  name   :text
#  org_id :text
#
# Indexes
#
#  IX_organisation_org_id  (org_id) UNIQUE
#

FactoryBot.define do
  factory :organisation do
    name { "LONDON SCITT" + rand(1000000).to_s }
    sequence(:org_id)
  end
end
