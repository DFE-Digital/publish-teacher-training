# == Schema Information
#
# Table name: organisation
#
#  id     :integer          not null, primary key
#  name   :text
#  org_id :text
#

class Organisation < ApplicationRecord
  has_and_belongs_to_many :users
  has_and_belongs_to_many :providers
  has_many :nctl_organisations
end
