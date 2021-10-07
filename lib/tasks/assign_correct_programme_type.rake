namespace :assign_programme_types do
  desc "Assigning the correct programme types to fee funded, non-self-accredited, non-school direct courses"
  task run_funding_type_setter_method_on_fee_funded_courses: :environment do
    course_with_program_type = Course.where.not(program_type: nil)
    fee_funded_courses = course_with_program_type.select { |c| c.funding_type == "fee" }
    fee_funded_without_school_direct = fee_funded_courses.reject { |c| c.program_type == "school_direct_training_programme" }
    incorrect_school_direct_fee_funded = fee_funded_without_school_direct.reject(&:self_accredited?)

    incorrect_school_direct_fee_funded.each do |course|
      course.funding_type = course.funding_type
    end
  end
end
