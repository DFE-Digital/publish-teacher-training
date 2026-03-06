# frozen_string_literal: true

class SetNonUkEligibilityFlags < ActiveRecord::Migration[8.0]
  def up
    bursary_eligible_subjects = [
      "Ancient Greek",
      "Ancient Hebrew",
      "French",
      "German",
      "Italian",
      "Japanese",
      "Latin",
      "Mandarin",
      "Modern languages (other)",
      "Physics",
      "Russian",
      "Spanish",
    ]

    scholarship_eligible_subjects = %w[
      French
      German
      Physics
      Spanish
    ]

    bursary_eligible_ids = Subject.where(subject_name: bursary_eligible_subjects).pluck(:id)
    scholarship_eligible_ids = Subject.where(subject_name: scholarship_eligible_subjects).pluck(:id)

    FinancialIncentive.where(subject_id: bursary_eligible_ids).update_all(non_uk_bursary_eligible: true)
    FinancialIncentive.where(subject_id: scholarship_eligible_ids).update_all(non_uk_scholarship_eligible: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
