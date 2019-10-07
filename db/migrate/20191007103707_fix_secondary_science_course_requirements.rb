class FixSecondaryScienceCourseRequirements < ActiveRecord::Migration[6.0]
  def up
    # There is no requirement for Science for secondary courses
    say_with_time "setting secondary science course requirements to not_set" do
      Course.where(level: "secondary").where.not(science: nil).update_all(science: nil)
    end
  end
end
