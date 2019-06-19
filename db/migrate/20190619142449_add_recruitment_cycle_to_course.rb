class AddRecruitmentCycleToCourse < ActiveRecord::Migration[5.2]
  def change
    add_reference :course, :recruitment_cycle, index: true, type: :int
  end
end
