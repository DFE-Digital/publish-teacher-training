# frozen_string_literal: true

class RecentSearch < ApplicationRecord
  include Discard::Model

  belongs_to :candidate, foreign_key: :find_candidate_id

  validates :search_attributes, search_attributes: true

  scope :active, -> { kept.order(updated_at: :desc) }
  scope :stale, -> { where(updated_at: ..30.days.ago) }
  scope :for_display, -> { active.limit(10) }

  def search_params
    params = search_attributes.symbolize_keys
    params[:subjects] = subjects if subjects.present?
    params[:longitude] = longitude if longitude.present?
    params[:latitude] = latitude if latitude.present?
    params[:radius] = radius if radius.present?
    params
  end
end
