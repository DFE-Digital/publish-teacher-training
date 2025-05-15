class CreateCandidate < ActiveRecord::Migration[8.0]
  def change
    create_table :candidate do |t|
      t.string :email_address

      t.timestamps
    end
  end
end
