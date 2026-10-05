# frozen_string_literal: true

class AddDegreeDependentToFinancialIncentive < ActiveRecord::Migration[8.1]
  def change
    add_column :financial_incentive, :degree_dependent, :boolean, null: false, default: false
  end
end
