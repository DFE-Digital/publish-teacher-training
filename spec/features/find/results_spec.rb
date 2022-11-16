require "rails_helper"

feature "results" do
  scenario "when I visit the results page with no courses" do
    when_i_visit_the_results_page
    i_see_the_no_results_message
  end

  scenario "when I visit the results page with courses" do
    given_there_are_courses
    when_i_visit_the_results_page
    i_see_the_courses
  end

  def when_i_visit_the_results_page
    results_page.load
  end

  def i_see_the_no_results_message
    expect(page).to have_content("You can try another search, for example by changing subjects or location")
  end

  def given_there_are_courses
    create_list(:course, 5, name: "Hello there")
  end

  def i_see_the_courses
    expect(results_page.courses.count).to eq(5)
    results_page.courses.first.then do |first_course|
      expect(first_course.course_name.text).to include("Hello there")
      expect(first_course.provider_name.text).to be_present
      expect(first_course.qualification.text).to include("PGCE with QTS")
      expect(first_course.study_mode.text).to eq("Full time")
      expect(first_course.funding_options.text).to eq("Salary")
    end
  end
end
