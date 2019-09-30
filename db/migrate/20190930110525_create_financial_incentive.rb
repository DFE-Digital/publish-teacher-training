class CreateFinancialIncentive < ActiveRecord::Migration[6.0]
  def change
    create_table :financial_incentive do |t|
      t.belongs_to :subject, null: false, foreign_key: true
      t.string :bursary_amount
      t.string :early_career_payments
      t.string :scholarship

      t.timestamps
    end
  end
end
