class DropPGDECourse < ActiveRecord::Migration[5.2]
  def up
    drop_table :pgde_course
  end

  def down
    raise ActiveRecord::IrreversibleMigration, " The 'pgde_course' table was only used when the course data comes from UCAS."
  end
end
