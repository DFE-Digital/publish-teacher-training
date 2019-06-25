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
  has_many :providers

  scope :accredited_body, -> { where(urn: nil) }
  scope :school, -> { where.not(urn: nil) }

  def accredited_body?
    urn.nil?
  end

  def courses
    Course.where(provider: providers)
  end

  def courses_accredited_by_this_organisation
    Course.where(accrediting_provider: providers)
  end

  def to_s
    "#{name} (#{nctl_id})"
  end
end
