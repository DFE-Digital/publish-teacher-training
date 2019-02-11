# == Schema Information
#
# Table name: organisation
#
#  id     :integer          not null, primary key
#  name   :text
#  org_id :text
#

class Organisation < ApplicationRecord
  has_many :organisation_users
  has_many :users, through: :organisation_users
  has_many :organisation_providers
  has_many :providers, through: :organisation_providers
end
