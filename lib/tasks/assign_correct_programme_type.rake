namespace :assign_programme_types do
  desc "Assigning the correct programme types to fee funded, non-self-accredited, non-school direct courses"
  task run_funding_type_setter_method_on_fee_funded_courses: :environment do
    fee_funded_courses = Course.select { |c| c.funding_type == "fee" }

    fee_funded_courses.each do |course|
      course.funding_type = course.funding_type
    end
  end
end
