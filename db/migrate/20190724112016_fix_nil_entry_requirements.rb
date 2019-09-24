class FixNilEntryRequirements < ActiveRecord::Migration[5.2]
  def up
    say_with_time "fixing courses with a nil subject requirement for required subjects" do
      Course
        .includes(:subjects)
        .select { |c| c.maths.nil? || c.english.nil? || (c.gcse_science_required? && c.science.nil?) }
        .each do |course|
        course.maths = "equivalence_test" if course.maths.nil?
        course.english = "equivalence_test" if course.english.nil?
        course.science = "equivalence_test" if course.science.nil?
        course.save
      end
    end
  end
end
