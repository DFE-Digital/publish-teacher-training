# frozen_string_literal: true

class NullifyBlankFinancialIncentiveAmounts < ActiveRecord::Migration[8.1]
  AMOUNTS = %w[bursary_amount scholarship early_career_payments].freeze

  def up
    AMOUNTS.each do |column|
      FinancialIncentive.where("btrim(#{column}) = ''").update_all(column => nil)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
