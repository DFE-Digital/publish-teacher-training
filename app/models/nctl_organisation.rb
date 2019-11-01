# == Schema Information
#
# Table name: nctl_organisation
#
#  id              :integer          not null, primary key
#  name            :text
#  nctl_id         :text             not null
#  organisation_id :integer
#
# Indexes
#
#  IX_nctl_organisation_organisation_id  (organisation_id)
#

class NCTLOrganisation < ApplicationRecord
  belongs_to :organisation
end
