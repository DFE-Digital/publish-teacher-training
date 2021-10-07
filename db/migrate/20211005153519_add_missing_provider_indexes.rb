class AddMissingProviderIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :provider, :can_sponsor_student_visa
  end
end
