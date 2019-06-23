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
  include AllocationsReport

  belongs_to :organisation

  scope :accredited_body, -> { where(urn: nil) }
  scope :school, -> { where.not(urn: nil) }

  def accredited_body?
    urn.nil?
  end

  def courses
    organisation
      .provider_for(self)
      .courses#.not_discontinued
      .includes(:provider,
               :subjects,
               provider: { organisations: :nctl_organisations })
  end

  def provider
    organisation.provider_for(self)
  end
end
