class AddSiteStatusIndexes < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :course_site, :publish, algorithm: :concurrently
    add_index :course_site, :status, algorithm: :concurrently
    add_index :course_site, :vac_status, algorithm: :concurrently
  end
end
