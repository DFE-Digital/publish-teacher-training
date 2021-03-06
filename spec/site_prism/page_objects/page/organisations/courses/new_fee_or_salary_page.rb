module PageObjects
  module Page
    module Organisations
      module Courses
        class NewFeeOrSalaryPage < NewCourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/fee-or-salary/new{?query*}"

          section :funding_type_fields, '[data-qa="course__funding_type"]' do
            element :apprenticeship, '[data-qa="course__funding_type_apprenticeship"]'
            element :fee, '[data-qa="course__funding_type_fee"]'
            element :salaried, '[data-qa="course__funding_type_salary"]'
          end
        end
      end
    end
  end
end
