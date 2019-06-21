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

class NCTLOrganisation < ApplicationRecord
  belongs_to :organisation

  scope :accredited_body, -> { where(urn: nil) }
  scope :school, -> { where.not(urn: nil) }
end
