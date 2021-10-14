namespace :assign_programme_types do
  desc "Assigning the correct programme types to fee funded, non-self-accredited, non-school direct courses"
  task run_funding_type_setter_method_on_fee_funded_courses: :environment do
    fee_funded_courses = Course.with_funding_types("fee")

    fee_funded_courses.find_each(batch_size: 500) do |course|
      course.funding_type = course.funding_type
    end
  end
end
