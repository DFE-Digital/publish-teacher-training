# == Schema Information
#
# Table name: organisation_user
#
#  id              :integer          not null, primary key
#  organisation_id :integer
#  user_id         :integer
#
# Indexes
#
#  IX_organisation_user_organisation_id                    (organisation_id)
#  IX_organisation_user_user_id                            (user_id)
#  index_organisation_user_on_organisation_id_and_user_id  (organisation_id,user_id) UNIQUE
#

class OrganisationUser < ApplicationRecord
  belongs_to :organisation
  belongs_to :user

  audited associated_with: :organisation
end
