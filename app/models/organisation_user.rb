# == Schema Information
#
# Table name: organisation_user
#
#  id              :integer          not null, primary key
#  organisation_id :integer
#  user_id         :integer
#

class OrganisationUser < ApplicationRecord
  belongs_to :organisation
  belongs_to :user
end
