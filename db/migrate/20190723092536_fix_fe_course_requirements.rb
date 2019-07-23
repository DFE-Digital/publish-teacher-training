class FixFeCourseRequirements < ActiveRecord::Migration[5.2]
  def up
    say_with_time 'setting further education course requirements to not_required' do
      Course.includes(:subjects).select { |course| course.level == :further_education }.each do |course|
        course.update(maths: :not_required, english: :not_required, science: :not_required)
      end
    end
  end
end
