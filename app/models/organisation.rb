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

  # This isn't used by the code anywhere but is needed by the AddNCTLOrganisationIdToProvider migration
  def nctl_organisation_for(provider)
    potential_organisations = if provider.accredited_body?
                                nctl_organisations.accredited_body
                              else
                                nctl_organisations.school
                              end

    if potential_organisations.size <= 1
      potential_organisations.first
    else
      raise "Multiple potential NCTL orgs found: #{potential_organisations.pluck(:nctl_id).join(', ')} for provider #{provider.provider_code}"
    end
  end
end
