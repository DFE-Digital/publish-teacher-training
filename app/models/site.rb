# == Schema Information
#
# Table name: site
#
#  id                   :integer          not null, primary key
#  address2             :text
#  address3             :text
#  address4             :text
#  code                 :text             not null
#  location_name        :text
#  postcode             :text
#  address1             :text
#  provider_id          :integer          default(0), not null
#  region_code          :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  recruitment_cycle_id :integer          not null
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
  belongs_to :recruitment_cycle

  validates :location_name, uniqueness: { scope: :provider_id }
  validates :location_name,
            :address1,
            :address3,
            :postcode,
            presence: true
  validates :postcode, postcode: true
  validates :code, uniqueness: { scope: :provider_id, case_sensitive: false },
                   inclusion: { in: POSSIBLE_CODES, message: "must be A-Z, 0-9 or -" },
                   presence: true

  def assign_code
    self.code ||= pick_next_available_code(available_codes: provider&.unassigned_site_codes)
  end

  def to_s
    "#{location_name} (code: #{code})"
  end

private

  def pick_next_available_code(available_codes: [])
    available_desirable_codes = available_codes & DESIRABLE_CODES
    available_undesirable_codes = available_codes & EASILY_CONFUSED_CODES
    available_desirable_codes.sample || available_undesirable_codes.sample
  end
end
