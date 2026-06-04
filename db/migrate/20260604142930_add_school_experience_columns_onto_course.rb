class AddSchoolExperienceColumnsOntoCourse < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      change_table :course, bulk: true do |t|
        t.column :school_experience_required, :boolean
        t.column :school_experience_required_content, :text
      end
    end
  end
end
