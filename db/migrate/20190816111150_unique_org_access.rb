class UniqueOrgAccess < ActiveRecord::Migration[5.2]
  def change
    add_index :organisation_user, %i[organisation_id user_id], unique: true
  end
end
