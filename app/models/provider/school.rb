# frozen_string_literal: true

class Provider::School < ApplicationRecord
  include TouchProvider

  self.table_name = "provider_school"

  MAIN_SITE_CODE = "-"

  after_destroy :touch_provider

  belongs_to :provider, class_name: "::Provider", inverse_of: :schools
  belongs_to :gias_school

  has_many :course_schools, class_name: "Course::School", inverse_of: :provider_school, dependent: :destroy

  # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
  # TODO School data remodel removal - drop legacy_site and register_import?
  # once the pickers no longer surface rollover cues that only Site records.
  #
  # provider_school.uuid is a copy of site.uuid while legacy sites are still
  # written, by both the dual-write in
  # Publish::Providers::Schools::ChecksController and the schools backfill. The
  # pairing breaks after rollover, when ProviderCopier mints fresh uuids, and
  # this association correctly returns nil from then on.
  has_one :legacy_site,
          -> { kept.where(site_type: :school) },
          class_name: "::Site",
          primary_key: :uuid,
          foreign_key: :uuid,
          inverse_of: false,
          dependent: nil
  # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective

  delegate :recruitment_cycle, :provider_code, to: :provider, allow_nil: true
  delegate :urn, :address1, :address2, :address3, :town, :postcode, to: :gias_school

  validates :site_code, presence: true
  validates :gias_school_id, uniqueness: { scope: %i[provider_id site_code] }
  validates :site_code,
            uniqueness: {
              scope: :provider_id,
              conditions: -> { where(site_code: MAIN_SITE_CODE) },
              message: :only_one_main_site_per_provider,
            },
            if: -> { site_code == MAIN_SITE_CODE }

  def location_name
    return "#{gias_school.name} (Main Site)" if main_site?

    gias_school.name
  end

  def main_site?
    site_code == MAIN_SITE_CODE
  end

  def code
    site_code
  end

  # Whether the school arrived through the register import, which the pickers
  # tag during the 2026 rollover. Only the legacy site records this.
  def register_import?
    legacy_site&.register_import? || false
  end

  def full_address(join_on_separator = ", ")
    [
      gias_school.address1,
      gias_school.address2,
      gias_school.address3,
      gias_school.town,
      gias_school.county,
      gias_school.postcode,
    ].compact_blank.join(join_on_separator)
  end
end
