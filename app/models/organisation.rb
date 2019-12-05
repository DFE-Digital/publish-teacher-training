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

class Organisation < ApplicationRecord
  has_many :organisation_users

  has_many :users, through: :organisation_users

  has_and_belongs_to_many :providers

  has_many :nctl_organisations

  validates :name, presence: true

  has_associated_audits
  audited

  def add_user(user)
    users << user
  end
end
