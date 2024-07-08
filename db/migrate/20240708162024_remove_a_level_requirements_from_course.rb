class RemoveALevelRequirementsFromCourse < ActiveRecord::Migration[7.1]
  def change
    change_table :course, bulk: true do |t|
      t.remove :a_level_requirements, type: :boolean
    end
  end
end
