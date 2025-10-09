# frozen_string_literal: true

class AddMissing2026SubjectsFinancialIncentives < ActiveRecord::Migration[7.2]
  def up
    say_with_time "adding missing 2026 financial incentives (Latin, Ancient Greek, Ancient Hebrew)" do
      year = 2026

      Subjects::FinancialIncentiveCreatorService.new(year:).execute
    end
  end

  def down
    say_with_time "reverting to 2025 financial incentives" do
      year = 2025

      Subjects::FinancialIncentiveCreatorService.new(year:).execute
    end
  end
end
