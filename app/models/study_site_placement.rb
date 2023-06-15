# frozen_string_literal: true

class StudySitePlacement < ApplicationRecord
  belongs_to :course, inverse_of: :study_site_placements
  belongs_to :site, inverse_of: :study_site_placements

  validate :site_type_cannot_be_school

  private

  def site_type_cannot_be_school
    return unless site.present? && site.school?

    errors.add(:site, 'cannot be a school')
  end
end
