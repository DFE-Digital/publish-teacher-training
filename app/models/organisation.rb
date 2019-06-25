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

  def nctl_organisation_for(provider)
    potential_organisations = if provider.accredited_body?
                                nctl_organisations.accredited_body
                              else
                                nctl_organisations.school
                              end

    if potential_organisations.size <= 1
      potential_organisations.first
    else
      raise "Multiple potential NCTL orgs found: #{potential_organisations.pluck(:nctl_id).join(", ")} for provider #{provider.provider_code}"
    end
  end

  def provider_for(nctl_organisation)
    potential_providers = providers.is_a_UCAS_ITT_member#.with_courses
    potential_providers = if nctl_organisation.accredited_body?
                            potential_providers.accredited_body
                          else
                            potential_providers
                              .not_an_accredited_body
                              .include_courses_counts
                              .to_a
                              .reject { |provider| provider.courses_count == 0 }
                          end

    if potential_providers.size <= 1
      potential_providers.first
    else
      raise "Multiple potential providers found: #{potential_providers.pluck(:provider_code).join(", ")} for NCTL org #{nctl_organisation.nctl_id}"
    end
  end
end
