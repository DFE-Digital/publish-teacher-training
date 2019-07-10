# == Schema Information
#
# Table name: site
#
#  id            :integer          not null, primary key
#  address2      :text
#  address3      :text
#  address4      :text
#  code          :text             not null
#  location_name :text
#  postcode      :text
#  address1      :text
#  provider_id   :integer          default(0), not null
#  region_code   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Site < ApplicationRecord
  include PostcodeNormalize
  include RegionCode
  include TouchProvider

  POSSIBLE_CODES = (('A'..'Z').to_a + ('0'..'9').to_a + ['-']).freeze
  EASILY_CONFUSED_CODES = %w[1 I 0 O -].freeze # these ought to be assigned last
  DESIRABLE_CODES = (POSSIBLE_CODES - EASILY_CONFUSED_CODES).freeze

  before_validation :assign_code, unless: :persisted?

  audited associated_with: :provider

  belongs_to :provider

  validates :location_name, uniqueness: { scope: :provider_id }
  validates :location_name,
            :address1,
            :postcode,
            presence: true
  validates :postcode, postcode: true
  validates :code, uniqueness: { scope: :provider_id, case_sensitive: false },
                   inclusion: { in: POSSIBLE_CODES, message: "must be A-Z, 0-9 or -" },
                   presence: true

  def recruitment_cycle
    provider.recruitment_cycle
  end

  def assign_code
    self.code ||= pick_next_available_code(available_codes: provider&.unassigned_site_codes)
  end

  def to_s
    "#{location_name} (code: #{code})"
  end

  def copy_to_provider(new_provider)
    new_site = new_provider.sites.find_by(code: self.code)
    unless new_site
      new_site = self.dup
      new_site.provider_id = new_provider.id
      new_site.save(validate: false)
      new_provider.reload
    end
  end

  def copy_to_course(new_course)
    new_vac_status = SiteStatus.default_vac_status_given(
      study_mode: new_course.study_mode
    )
    new_start_date = new_course.recruitment_cycle.application_start_date

    new_course.site_statuses.create(
      site: self,
      vac_status: new_vac_status,
      applications_accepted_from: new_start_date,
      status: :new_status
    )
  end

private

  def pick_next_available_code(available_codes: [])
    available_desirable_codes = available_codes & DESIRABLE_CODES
    available_undesirable_codes = available_codes & EASILY_CONFUSED_CODES
    available_desirable_codes.sample || available_undesirable_codes.sample
  end
end
