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

  def accredited_nctl_organisation
    nctl_organisations.accredited_body.first
  end

  def school_nctl_organisation
    if nctl_organisations.school.count > 1
      raise "more than one school nctl organisation found"
    end

    nctl_organisations.school.first
  end
end
