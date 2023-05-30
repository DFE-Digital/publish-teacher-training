# frozen_string_literal: true

class StudySitePlacement < ApplicationRecord
  belongs_to :course, inverse_of: :study_site_placements
  belongs_to :site, inverse_of: :study_site_placements
end
