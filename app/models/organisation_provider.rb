# == Schema Information
#
# Table name: organisation_provider
#
#  id              :integer          not null, primary key
#  provider_id     :integer
#  organisation_id :integer
#

class OrganisationProvider < ApplicationRecord
  belongs_to :provider
  belongs_to :organisation
end
