class FixSecondaryScienceCourseRequirements < ActiveRecord::Migration[6.0]
  def up
    # There is no requirement for Science for secondary courses
    say_with_time "setting secondary science course requirements to not_set" do
      Course.select { |course| course.level == "secondary" && !course.science.nil? }.each do |course|
        course.update(science: nil)
      end
    end
  end
end
