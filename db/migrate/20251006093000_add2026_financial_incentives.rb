# frozen_string_literal: true

class Add2026FinancialIncentives < ActiveRecord::Migration[7.2]
  def up
    say_with_time "populating 2026 financial incentives" do
      FinancialIncentive.destroy_all

      year = 2026

      Subjects::FinancialIncentiveCreatorService.new(year:).execute
    end
  end

  def down
    say_with_time "populating 2025 financial incentives" do
      FinancialIncentive.destroy_all

      year = 2025

      Subjects::FinancialIncentiveCreatorService.new(year:).execute
    end
  end
end
