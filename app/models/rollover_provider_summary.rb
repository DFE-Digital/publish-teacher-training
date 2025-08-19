class RolloverProviderSummary < ApplicationRecord
  belongs_to :provider
  belongs_to :target_recruitment_cycle, class_name: "RecruitmentCycle"

  validates :provider_code, presence: true
  validates :status, presence: true, inclusion: { in: %w[started completed failed skipped] }

  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }
  scope :for_cycle, ->(cycle_id) { where(target_recruitment_cycle_id: cycle_id) }

  def completed?
    status == "completed"
  end

  def failed?
    status == "failed"
  end

  def skipped?
    status == "skipped"
  end

  def providers_copied
    summary_data&.dig("providers") || 0
  end

  def sites_copied
    summary_data&.dig("sites") || 0
  end

  def courses_copied
    summary_data&.dig("courses") || 0
  end
end
