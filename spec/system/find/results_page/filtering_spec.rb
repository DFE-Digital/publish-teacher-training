# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Search Results", :js, service: :find do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  scenario "when I filter by visa sponsorship" do
    given_there_are_courses_that_sponsor_visa
    and_there_are_courses_that_do_not_sponsor_visa
    when_i_visit_the_find_results_page
    and_i_filter_by_courses_that_sponsor_visa
    then_i_see_only_courses_that_sponsor_visa
    and_the_visa_sponsorship_filter_is_checked
    and_i_see_that_three_courses_are_found
  end

  scenario "when I filter by study type" do
    given_there_are_courses_containing_all_study_types
    when_i_visit_the_find_results_page
    and_i_filter_only_by_part_time_courses
    then_i_see_only_part_time_courses
    and_the_part_time_filter_is_checked
    when_i_filter_only_by_full_time_courses
    then_i_see_only_full_time_courses
    and_the_full_time_filter_is_checked
    when_i_filter_by_part_time_and_full_time_courses
    then_i_see_all_courses_containing_all_study_types
    and_the_part_time_filter_is_checked
    and_the_full_time_filter_is_checked
  end

  scenario "when I filter by QTS-only courses" do
    given_there_are_courses_containing_all_qualifications
    when_i_visit_the_find_results_page
    and_i_filter_by_qts_only_courses
    then_i_see_only_qts_only_courses
    and_the_qts_only_filter_is_checked
    and_i_see_that_there_is_one_course_found
  end

  scenario "when I filter by QTS with PGCE" do
    given_there_are_courses_containing_all_qualifications
    when_i_visit_the_find_results_page
    and_i_filter_by_qts_with_pgce_or_pgde_courses
    then_i_see_only_qts_with_pgce_or_pgde_courses
    and_the_qts_with_pgce_or_pgde_filter_is_checked
    and_i_see_that_two_courses_are_found
  end

  context "when filtering by minimum degree requirement" do
    before do
      given_there_are_courses_with_various_degree_requirements
    end

    scenario "when 2:1 degree requirement shows courses requiring 2:1, 2:2, third-class, or pass degrees" do
      when_i_visit_the_find_results_page
      and_i_filter_courses_requiring_two_one_degree
      then_courses_with_two_one_or_lower_degree_requirement_are_visible
      and_the_two_one_filter_is_checked
      and_i_see_that_four_courses_are_found
    end

    scenario "when 2:2 degree requirement shows courses requiring 2:2, third-class, or pass degrees" do
      when_i_visit_the_find_results_page
      and_i_filter_courses_requiring_two_two_degree
      then_courses_with_two_two_or_lower_degree_requirement_are_visible
      and_the_two_two_filter_is_checked
      and_i_see_that_three_courses_are_found
    end

    scenario 'when "Third class" shows courses requiring third-class or an ordinary degree' do
      when_i_visit_the_find_results_page
      and_i_filter_courses_requiring_third_class_grade
      then_courses_with_third_class_or_lower_degree_requirement_are_visible
      and_the_third_class_filter_is_checked
      and_i_see_that_two_courses_are_found
    end

    scenario 'when "Pass" shows courses requiring an ordinary degree' do
      when_i_visit_the_find_results_page
      and_i_filter_courses_requiring_pass_grade
      then_only_courses_with_ordinary_degree_requirement_are_visible
      and_the_pass_filter_is_checked
      and_i_see_that_there_is_one_course_found
    end

    scenario "filtering by 'No degree required' shows only undergraduate courses" do
      when_i_visit_the_find_results_page
      and_i_filter_courses_with_no_degree_requirement
      then_only_undergraduate_courses_are_visible
      and_the_no_degree_required_filter_is_checked
      and_i_see_that_there_is_one_course_found
    end

    scenario "legacy parameters for 2:1 degree requirements shows relevant courses" do
      when_i_visit_the_find_results_page_using_old_two_one_parameter
      then_courses_with_two_one_or_lower_degree_requirement_are_visible
      and_the_two_one_filter_is_checked
      and_i_see_that_four_courses_are_found
    end

    scenario "legacy parameters for 2:2 degree requirements shows relevant courses" do
      when_i_visit_the_find_results_page_using_old_two_two_parameter
      then_courses_with_two_two_or_lower_degree_requirement_are_visible
      and_the_two_two_filter_is_checked
      and_i_see_that_three_courses_are_found
    end

    scenario "legacy parameters for third class degree requirements shows relevant courses" do
      when_i_visit_the_find_results_page_using_old_third_class_parameter
      then_courses_with_third_class_or_lower_degree_requirement_are_visible
      and_the_third_class_filter_is_checked
      and_i_see_that_two_courses_are_found
    end

    scenario "legacy parameters for pass degree requirements shows relevant courses" do
      when_i_visit_the_find_results_page_using_old_pass_parameter
      then_only_courses_with_ordinary_degree_requirement_are_visible
      and_the_pass_filter_is_checked
      and_i_see_that_there_is_one_course_found
    end

    scenario "legacy parameters for undergraduate courses shows relevant courses" do
      when_i_visit_the_find_results_page_using_old_undergraduate_courses_parameter
      then_only_undergraduate_courses_are_visible
      and_the_no_degree_required_filter_is_checked
      and_i_see_that_there_is_one_course_found
    end
  end

  scenario "when I filter by applications open" do
    given_there_are_courses_open_for_applications
    and_there_are_courses_that_are_closed_for_applications
    when_i_visit_the_find_results_page
    and_i_filter_by_courses_open_for_applications
    then_i_see_only_courses_that_are_open_for_applications
    and_the_open_for_application_filter_is_checked
  end

  scenario "when I filter by special educational needs" do
    given_there_are_courses_with_special_education_needs
    and_there_are_courses_that_with_no_special_education_needs
    when_i_visit_the_find_results_page
    and_i_filter_by_courses_with_special_education_needs
    then_i_see_only_courses_with_special_education_needs
    and_the_special_education_needs_filter_is_checked
  end

  context "when filter by funding type" do
    before do
      given_there_are_courses_with_all_funding_types
    end

    scenario "when I filter by salaried" do
      when_i_visit_the_find_results_page
      and_i_filter_by_salaried_courses
      then_i_see_only_salaried_courses
      and_the_salary_filter_is_checked
      and_i_see_that_there_is_one_course_found
    end

    scenario "when I filter by fee" do
      when_i_visit_the_find_results_page
      and_i_filter_by_fee_courses
      then_i_see_only_fee_courses
      and_the_fee_filter_is_checked
      and_i_see_that_there_is_one_course_found
    end

    scenario "when I filter by fee and salaried" do
      when_i_visit_the_find_results_page
      and_i_filter_by_fee_courses
      and_i_filter_by_salaried_courses
      then_i_see_fee_and_salaried_courses
      and_the_fee_filter_is_checked
      and_the_salary_filter_is_checked
      and_i_see_that_two_courses_are_found
    end

    scenario "when I use the old funding parameter" do
      when_i_visit_the_find_results_page_using_old_salary_parameter
      then_i_see_only_salaried_courses
      and_the_salary_filter_is_checked
      and_i_see_that_there_is_one_course_found
    end

    scenario "when I filter by apprenticeship" do
      when_i_visit_the_find_results_page
      and_i_filter_by_apprenticeship_courses
      then_i_see_only_apprenticeship_courses
      and_the_apprenticeship_filter_is_checked
      and_i_see_that_there_is_one_course_found
    end
  end

  context "when filter by subjects" do
    before do
      given_there_are_courses_with_secondary_subjects
      and_there_are_courses_with_primary_subjects
      when_i_visit_the_find_results_page
    end

    scenario "filter by specific primary subjects" do
      when_i_filter_by_primary
      then_i_see_only_primary_specific_courses
      and_the_primary_option_is_checked
      and_i_see_that_there_is_one_course_found

      when_i_filter_by_primary_with_science_too
      then_i_see_primary_and_primary_with_science_courses
      and_the_primary_option_is_checked
      and_the_primary_with_science_option_is_checked
      and_i_see_that_two_courses_are_found
    end

    scenario "filter by specific secondary subjects" do
      and_i_search_for_the_mathematics_option
      then_i_can_only_see_the_mathematics_option
      when_i_clear_my_search_for_secondary_options
      then_i_can_see_all_secondary_options
      when_i_filter_by_mathematics
      then_i_see_only_mathematics_courses
      and_the_mathematics_secondary_option_is_checked
      and_i_see_that_there_is_one_course_found

      when_i_search_for_specific_secondary_options
      then_i_can_only_see_options_that_i_searched

      when_i_clear_my_search_for_secondary_options
      then_i_can_see_all_secondary_options
    end

    scenario "filter by many secondary subjects" do
      and_i_filter_by_mathematics
      and_i_filter_by_chemistry
      then_i_see_mathematics_and_chemistry_courses
      and_the_mathematics_secondary_option_is_checked
      and_the_chemistry_secondary_option_is_checked
      and_i_see_that_two_courses_are_found
    end

    scenario "passing subjects on the parameters" do
      when_i_visit_the_find_results_page_passing_mathematics_in_the_params
      then_i_see_only_mathematics_courses
      and_the_mathematics_secondary_option_is_checked
      and_i_see_that_there_is_one_course_found
    end
  end

  context "when filtering by start date" do
    before do
      given_courses_exist_with_varied_start_dates
      when_i_visit_the_find_results_page
    end

    scenario "filtering by September start date" do
      when_i_filter_by_september_start_date
      and_i_apply_the_filters
      then_i_see_only_courses_starting_in_september
      and_i_see_that_three_courses_are_found
    end

    scenario "filtering by all other start dates" do
      when_i_filter_by_non_september_start_dates
      and_i_apply_the_filters
      then_i_see_only_courses_not_starting_in_september
      and_i_see_that_three_courses_are_found
    end

    scenario "filtering by all available start dates" do
      when_i_filter_by_all_start_date_options
      and_i_apply_the_filters
      then_i_see_all_courses_regardless_of_start_date
      and_i_see_that_six_courses_are_found
    end
  end

  context "when searching for engineers teach physics" do
    before do
      given_there_are_courses_with_secondary_subjects
      and_there_are_courses_with_primary_subjects
      when_i_visit_the_find_results_page
    end

    scenario "when searching for physics" do
      then_engineers_teach_physics_filter_is_not_visible

      when_i_check_physics
      and_i_apply_the_filters
      then_engineers_teach_physics_filter_is_visible
      and_physics_and_engineers_teach_physics_courses_are_visible
      and_i_see_that_two_courses_are_found

      when_i_check_engineers_teach_physics_only_filter
      and_i_apply_the_filters
      then_engineers_teach_physics_filter_is_visible
      and_only_engineers_teach_physics_courses_are_visible
      and_i_see_that_there_is_one_course_found

      when_i_uncheck_physics
      and_i_apply_the_filters
      then_engineers_teach_physics_filter_is_not_visible
      and_i_see_that_ten_courses_are_found
    end

    scenario "when searching for physics on subjects field" do
      then_engineers_teach_physics_filter_is_not_visible

      when_i_search_for_physics_in_subjects_autocomplete
      and_i_select_the_first_subject_suggestion
      and_i_click_search
      then_engineers_teach_physics_filter_is_visible
      and_physics_and_engineers_teach_physics_courses_are_visible
      and_i_see_that_two_courses_are_found

      and_i_remove_the_subject
      and_i_click_search
      then_engineers_teach_physics_filter_is_not_visible
    end
  end

  def given_there_are_courses_that_sponsor_visa
    create(:course, :with_full_time_sites, :can_sponsor_skilled_worker_visa, name: "Biology", course_code: "S872")
    create(:course, :with_full_time_sites, :can_sponsor_student_visa, name: "Chemistry", course_code: "K592")
    create(:course, :with_full_time_sites, :can_sponsor_student_visa, :can_sponsor_skilled_worker_visa, name: "Computing", course_code: "L364")
  end

  def given_there_are_courses_containing_all_study_types
    create(:course, :with_full_time_sites, study_mode: "full_time", name: "Biology", course_code: "S872")
    create(:course, :with_part_time_sites, study_mode: "part_time", name: "Chemistry", course_code: "K592")
    create(:course, :with_full_time_or_part_time_sites, study_mode: "full_time_or_part_time", name: "Computing", course_code: "L364")
  end

  def given_there_are_courses_with_secondary_subjects
    @biology_course = create(:course, :open, :with_full_time_sites, :secondary, name: "Biology", course_code: "S872", subjects: [find_or_create(:secondary_subject, :biology)])
    @chemistry_course = create(:course, :open, :with_full_time_sites, :secondary, name: "Chemistry", course_code: "K592", subjects: [find_or_create(:secondary_subject, :chemistry)])
    @computing_course = create(:course, :open, :with_full_time_sites, :secondary, name: "Computing", course_code: "L364", subjects: [find_or_create(:secondary_subject, :computing)])
    @mathematics_course = create(:course, :open, :with_full_time_sites, :secondary, name: "Mathematics", course_code: "4RTU", subjects: [find_or_create(:secondary_subject, :mathematics)])
    @physics_course = create(:course, :open, :with_full_time_sites, :secondary, name: "Physics", course_code: "3DDW", subjects: [find_or_create(:secondary_subject, :physics)])
    @engineers_teach_physics_course = create(:course, :open, :with_full_time_sites, :secondary, :engineers_teach_physics, name: "Engineers Teach Physics", course_code: "R232", subjects: [find_or_create(:secondary_subject, :physics)])
  end

  def and_there_are_courses_with_primary_subjects
    create(:course, :open, :with_full_time_sites, :primary, name: "Primary", course_code: "S872", subjects: [find_or_create(:primary_subject, :primary)])
    create(:course, :open, :with_full_time_sites, :primary, name: "Primary with english", course_code: "K592", subjects: [find_or_create(:primary_subject, :primary_with_english)])
    create(:course, :open, :with_full_time_sites, :primary, name: "Primary with mathematics", course_code: "L364", subjects: [find_or_create(:primary_subject, :primary_with_mathematics)])
    create(:course, :open, :with_full_time_sites, :primary, name: "Primary with science", course_code: "4RTU", subjects: [find_or_create(:primary_subject, :primary_with_science)])
  end

  def given_there_are_courses_containing_all_qualifications
    create(:course, :with_full_time_sites, qualification: "qts", name: "Biology", course_code: "S872")
    create(:course, :with_full_time_sites, qualification: "pgce_with_qts", name: "Chemistry", course_code: "K592")
    create(:course, :with_full_time_sites, qualification: "pgde_with_qts", name: "Computing", course_code: "L364")
    create(:course, :with_full_time_sites, qualification: "pgce", name: "Dance", course_code: "C115")
    create(:course, :with_full_time_sites, qualification: "pgde", name: "Physics", course_code: "3CXN")
    create(:course, :with_full_time_sites, qualification: "undergraduate_degree_with_qts", name: "Mathemathics", course_code: "4RTU")
  end

  def given_there_are_courses_with_various_degree_requirements
    create(:course, :published_postgraduate, degree_grade: "two_one", name: "Biology", course_code: "S872")
    create(:course, :published_postgraduate, degree_grade: "two_two", name: "Chemistry", course_code: "K592")
    create(:course, :published_postgraduate, degree_grade: "third_class", name: "Computing", course_code: "L364")
    create(:course, :published_postgraduate, degree_grade: "not_required", name: "Dance", course_code: "C115")
    create(:course, :published_teacher_degree_apprenticeship, degree_grade: "not_required", name: "Mathemathics", course_code: "4RTU")
  end

  def given_there_are_courses_containing_all_levels
    create(:course, :with_full_time_sites, :primary, name: "Biology", course_code: "S872")
    create(:course, :with_full_time_sites, :secondary, name: "Chemistry", course_code: "K592")
    create(:course, :with_full_time_sites, :further_education, name: "Further education", course_code: "K594")
  end

  def given_there_are_courses_open_for_applications
    create(:course, :with_full_time_sites, :open, name: "Biology", course_code: "S872")
    create(:course, :with_full_time_sites, :open, name: "Chemistry", course_code: "K592")
    create(:course, :with_full_time_sites, :open, name: "Computing", course_code: "L364")
  end

  def and_there_are_courses_that_are_closed_for_applications
    create(:course, :with_full_time_sites, :closed, name: "Dance", course_code: "C115")
    create(:course, :with_full_time_sites, :closed, name: "Physics", course_code: "3CXN")
  end

  def given_there_are_courses_with_special_education_needs
    create(:course, :with_full_time_sites, :with_special_education_needs, name: "Biology SEND", course_code: "S872")
    create(:course, :with_full_time_sites, :with_special_education_needs, name: "Chemistry SEND", course_code: "K592")
    create(:course, :with_full_time_sites, :with_special_education_needs, name: "Computing SEND", course_code: "L364")
  end

  def given_there_are_courses_with_all_funding_types
    create(:course, :with_full_time_sites, :fee_type_based, name: "Biology", course_code: "S872")
    create(:course, :with_full_time_sites, :with_salary, name: "Chemistry", course_code: "K592")
    create(:course, :with_full_time_sites, :with_apprenticeship, name: "Computing", course_code: "L364")
  end

  def and_there_are_courses_that_with_no_special_education_needs
    create(:course, :with_full_time_sites, is_send: false, can_sponsor_student_visa: false, name: "Dance", course_code: "C115")
    create(:course, :with_full_time_sites, is_send: false, name: "Physics", course_code: "3CXN")
  end

  def and_there_are_courses_that_do_not_sponsor_visa
    create(:course, :with_full_time_sites, can_sponsor_skilled_worker_visa: false, can_sponsor_student_visa: false, name: "Dance", course_code: "C115")
  end

  def when_i_visit_the_find_results_page
    visit find_results_path
  end

  def when_i_visit_the_find_results_page_using_old_salary_parameter
    visit(find_results_path(funding: "salary"))
  end

  def when_i_visit_the_find_results_page_passing_mathematics_in_the_params
    visit(find_results_path(subjects: %w[G1]))
  end

  def when_i_visit_the_find_results_page_using_the_old_age_group_parameter
    visit(find_results_path(age_group: "further_education"))
  end

  def when_i_visit_the_find_results_page_using_the_old_pgce_pgde_parameter
    visit(find_results_path(qualification: ["pgce pgde"]))
  end

  def when_i_visit_the_find_results_page_using_old_two_one_parameter
    visit(find_results_path(degree_required: "show_all_courses"))
  end

  def when_i_visit_the_find_results_page_using_old_two_two_parameter
    visit(find_results_path(degree_required: "two_two"))
  end

  def when_i_visit_the_find_results_page_using_old_third_class_parameter
    visit(find_results_path(degree_required: "third_class"))
  end

  def when_i_visit_the_find_results_page_using_old_pass_parameter
    visit(find_results_path(degree_required: "not_required"))
  end

  def when_i_visit_the_find_results_page_using_old_undergraduate_courses_parameter
    visit(find_results_path(university_degree_status: false))
  end

  def and_i_search_for_the_mathematics_option
    page.find('[data-filter-search-target="searchInput"]').set("Math")
  end

  def then_i_can_only_see_the_mathematics_option
    expect(secondary_options).to eq(%w[Mathematics])
  end

  def then_i_can_see_all_secondary_options
    expect(secondary_options.size).to eq(37)
  end

  def when_i_search_for_specific_secondary_options
    page.find('[data-filter-search-target="searchInput"]').set("Com")
  end

  def then_i_can_only_see_options_that_i_searched
    expect(secondary_options).to eq(["Communication and media studies", "Computing"])
  end

  def when_i_clear_my_search_for_secondary_options
    fill_in "filter-search-0-input", with: ""
  end

  def and_i_filter_by_courses_that_sponsor_visa
    check "Only show courses with visa sponsorship", visible: :all
    and_i_apply_the_filters
  end

  def when_i_filter_by_primary
    check "Primary", visible: :all
    and_i_apply_the_filters
  end

  def when_i_filter_by_primary_with_science_too
    check "Primary with science", visible: :all
    and_i_apply_the_filters
  end

  def when_i_filter_by_mathematics
    check "Mathematics", visible: :all
    and_i_apply_the_filters
  end
  alias_method :and_i_filter_by_mathematics, :when_i_filter_by_mathematics

  def and_i_filter_by_chemistry
    check "Chemistry", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_courses_requiring_two_two_degree
    choose "2:2", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_courses_requiring_pass_grade
    choose "Pass", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_courses_with_no_degree_requirement
    choose "No degree required", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_courses_requiring_two_one_degree
    choose "2:1 or First", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_courses_requiring_third_class_grade
    choose "Third", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_only_by_part_time_courses
    uncheck "Full time (12 months)", visible: :all
    check "Part time (18 to 24 months)", visible: :all
    and_i_apply_the_filters
  end

  def when_i_filter_only_by_full_time_courses
    uncheck "Part time (18 to 24 months)", visible: :all
    check "Full time (12 months)", visible: :all
    and_i_apply_the_filters
  end

  def when_i_filter_by_part_time_and_full_time_courses
    check "Part time (18 to 24 months)", visible: :all
    check "Full time (12 months)", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_qts_only_courses
    check "QTS only", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_qts_with_pgce_or_pgde_courses
    check "QTS with PGCE or PGDE", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_courses_open_for_applications
    check "Only show courses open for applications", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_further_education_courses
    check "Further education courses", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_courses_with_special_education_needs
    check "Only show courses with a SEND specialism", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_salaried_courses
    check "Salary", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_fee_courses
    check "Fee - no salary", visible: :all
    and_i_apply_the_filters
  end

  def and_i_filter_by_apprenticeship_courses
    check "Teaching apprenticeship - with salary", visible: :all
    and_i_apply_the_filters
  end

  def then_i_see_only_primary_specific_courses
    expect(results).to have_content("Primary (S872)")
    expect(results).to have_no_content("Primary with english")
    expect(results).to have_no_content("Primary with mathematics")
    expect(results).to have_no_content("Primary with science")
  end

  def then_i_see_primary_and_primary_with_science_courses
    expect(results).to have_content("Primary (S872)")
    expect(results).to have_content("Primary with science")
    expect(results).to have_no_content("Primary with english")
    expect(results).to have_no_content("Primary with mathematics")
  end

  def and_the_primary_option_is_checked
    expect(page).to have_checked_field("Primary", visible: :all)
  end

  def and_the_primary_with_science_option_is_checked
    expect(page).to have_checked_field("Primary with science", visible: :all)
  end

  def then_i_see_only_courses_that_sponsor_visa
    expect(results).to have_content("Biology (S872")
    expect(results).to have_content("Chemistry (K592)")
    expect(results).to have_content("Computing (L364)")
    expect(results).to have_no_content("Dance (C115)")
  end

  def then_i_see_only_part_time_courses
    expect(results).to have_content("Chemistry (K592)")
    expect(results).to have_content("Computing (L364)")
    expect(results).to have_no_content("Biology (S872)")
  end

  def and_the_part_time_filter_is_checked
    expect(page).to have_checked_field("Part time (18 to 24 months)", visible: :all)
  end

  def then_i_see_only_full_time_courses
    expect(results).to have_content("Biology (S872)")
    expect(results).to have_content("Computing (L364)")
    expect(results).to have_no_content("Chemistry (K592)")
  end

  def and_the_full_time_filter_is_checked
    expect(page).to have_checked_field("Full time (12 months)", visible: :all)
  end

  def and_the_two_two_filter_is_checked
    expect(page).to have_checked_field("2:2", visible: :all)
  end

  def and_the_third_class_filter_is_checked
    expect(page).to have_checked_field("Third", visible: :all)
  end

  def and_the_pass_filter_is_checked
    expect(page).to have_checked_field("Pass", visible: :all)
  end

  def and_the_no_degree_required_filter_is_checked
    expect(page).to have_checked_field("No degree required", visible: :all)
  end

  def and_the_two_one_filter_is_checked
    expect(page).to have_checked_field("2:1 or First", visible: :all)
  end

  def then_i_see_all_courses_containing_all_study_types
    expect(results).to have_content("Biology (S872)")
    expect(results).to have_content("Computing (L364)")
    expect(results).to have_content("Chemistry (K592)")
  end

  def then_i_see_only_qts_only_courses
    expect(results).to have_content("Biology (S872)")
    expect(results).to have_no_content("Chemistry (K592)")
    expect(results).to have_no_content("Computing (L364)")
    expect(results).to have_no_content("Dance (C115)")
    expect(results).to have_no_content("Physics (3CXN)")
    expect(results).to have_no_content("Mathemathics (4RTU)")
  end

  def and_the_qts_only_filter_is_checked
    expect(page).to have_checked_field("QTS only", visible: :all)
  end

  def then_i_see_only_qts_with_pgce_or_pgde_courses
    expect(results).to have_content("Chemistry (K592)")
    expect(results).to have_content("Computing (L364)")
    expect(results).to have_no_content("Biology (S872)")
    expect(results).to have_no_content("Dance (C115)")
    expect(results).to have_no_content("Physics (3CXN)")
    expect(results).to have_no_content("Mathemathics (4RTU)")
  end

  def and_the_qts_with_pgce_or_pgde_filter_is_checked
    expect(page).to have_checked_field("QTS with PGCE or PGDE", visible: :all)
  end

  def then_i_see_only_further_education__courses
    expect(results).to have_content("Further education (K594)")
    expect(results).to have_no_content("Biology (S872)")
    expect(results).to have_no_content("Chemistry (K592)")
  end

  def and_the_further_education_filter_is_checked
    expect(page).to have_checked_field("Further education courses", visible: :all)
  end

  def then_i_see_only_courses_with_special_education_needs
    expect(results).to have_content("Biology SEND (S872")
    expect(results).to have_content("Chemistry SEND (K592)")
    expect(results).to have_content("Computing SEND (L364)")
    expect(results).to have_no_content("Dance (C115)")
    expect(results).to have_no_content("Physics (3CXN)")
  end

  def then_i_see_only_salaried_courses
    expect(results).to have_content("Chemistry (K592)")
    expect(results).to have_no_content("Biology (S872)")
    expect(results).to have_no_content("Computing (L364)")
  end

  def then_i_see_only_fee_courses
    expect(results).to have_content("Biology (S872)")
    expect(results).to have_no_content("Chemistry (K592)")
    expect(results).to have_no_content("Computing (L364)")
  end

  def then_i_see_fee_and_salaried_courses
    expect(results).to have_content("Biology (S872)")
    expect(results).to have_content("Chemistry (K592)")
    expect(results).to have_no_content("Computing (L364)")
  end

  def then_i_see_only_apprenticeship_courses
    expect(results).to have_content("Computing (L364)")
    expect(results).to have_no_content("Chemistry (K592)")
    expect(results).to have_no_content("Biology (S872)")
  end

  def then_i_see_only_courses_that_are_open_for_applications
    expect(results).to have_content("Biology (S872)")
    expect(results).to have_content("Chemistry (K592)")
    expect(results).to have_content("Computing (L364)")
    expect(results).to have_no_content("Dance (C115)")
    expect(results).to have_no_content("Physics (3CXN)")
  end

  def and_the_visa_sponsorship_filter_is_checked
    expect(page).to have_checked_field("Only show courses with visa sponsorship", visible: :all)
  end

  def and_the_open_for_application_filter_is_checked
    expect(page).to have_checked_field("Only show courses open for applications", visible: :all)
  end

  def and_the_special_education_needs_filter_is_checked
    expect(page).to have_checked_field("Only show courses with a SEND specialism", visible: :all)
  end

  def and_the_fee_filter_is_checked
    expect(page).to have_checked_field("Fee - no salary", visible: :all)
  end

  def and_the_salary_filter_is_checked
    expect(page).to have_checked_field("Salary", visible: :all)
  end

  def and_the_apprenticeship_filter_is_checked
    expect(page).to have_checked_field("Teaching apprenticeship - with salary", visible: :all)
  end

  def and_i_apply_the_filters
    click_link_or_button "Apply filters", match: :first
  end

  def and_i_see_that_there_is_one_course_found
    expect(page).to have_content("1 course found")
    expect(page).to have_title("1 course found")
  end

  def and_i_see_that_two_courses_are_found
    expect(page).to have_content("2 courses found")
    expect(page).to have_title("2 courses found")
  end

  def and_i_see_that_three_courses_are_found
    expect(page).to have_content("3 courses found")
    expect(page).to have_title("3 courses found")
  end

  def and_i_see_that_four_courses_are_found
    expect(page).to have_content("4 courses found")
    expect(page).to have_title("4 courses found")
  end

  def then_i_see_only_mathematics_courses
    expect(results).to have_content("Mathematics (4RTU)")
    expect(results).to have_no_content("Biology")
    expect(results).to have_no_content("Chemistry")
    expect(results).to have_no_content("Computing")
  end

  def then_i_see_mathematics_and_chemistry_courses
    expect(results).to have_content("Mathematics")
    expect(results).to have_content("Chemistry")
    expect(results).to have_no_content("Biology")
    expect(results).to have_no_content("Computing")
  end

  def then_courses_with_two_one_or_lower_degree_requirement_are_visible
    expect(results).to have_content("Biology")
    expect(results).to have_content("Chemistry")
    expect(results).to have_content("Computing")
    expect(results).to have_content("Dance")
    expect(results).to have_no_content("Mathemathics")
  end

  def then_courses_with_two_two_or_lower_degree_requirement_are_visible
    expect(results).to have_content("Chemistry")
    expect(results).to have_content("Computing")
    expect(results).to have_content("Dance")
    expect(results).to have_no_content("Biology")
    expect(results).to have_no_content("Mathemathics")
  end

  def then_courses_with_third_class_or_lower_degree_requirement_are_visible
    expect(results).to have_content("Computing")
    expect(results).to have_content("Dance")
    expect(results).to have_no_content("Biology")
    expect(results).to have_no_content("Chemistry")
    expect(results).to have_no_content("Mathemathics")
  end

  def then_only_courses_with_ordinary_degree_requirement_are_visible
    expect(results).to have_content("Dance")
    expect(results).to have_no_content("Biology")
    expect(results).to have_no_content("Chemistry")
    expect(results).to have_no_content("Computing")
    expect(results).to have_no_content("Mathemathics")
  end

  def then_only_undergraduate_courses_are_visible
    expect(results).to have_content("Mathemathics")
    expect(results).to have_no_content("Biology")
    expect(results).to have_no_content("Dance")
    expect(results).to have_no_content("Chemistry")
    expect(results).to have_no_content("Computing")
  end

  def and_the_mathematics_secondary_option_is_checked
    expect(page).to have_checked_field("Mathematics", visible: :all)
  end

  def and_the_chemistry_secondary_option_is_checked
    expect(page).to have_checked_field("Chemistry", visible: :all)
  end

  def given_courses_exist_with_varied_start_dates
    @january_course = create(
      :course,
      :with_full_time_sites,
      name: "Art and design",
      start_date: DateTime.new(current_recruitment_cycle_year, 1, 1),
    )
    @august_course = create(
      :course,
      :with_full_time_sites,
      name: "Biology",
      start_date: DateTime.new(current_recruitment_cycle_year, 8, 1),
    )
    @beginning_of_september_course = create(
      :course,
      :with_full_time_sites,
      name: "Computing",
      start_date: DateTime.new(current_recruitment_cycle_year, 9, 1),
    )
    @middle_of_september_course = create(
      :course,
      :with_full_time_sites,
      name: "English",
      start_date: DateTime.new(current_recruitment_cycle_year, 9, 15),
    )
    @end_of_september_course = create(
      :course,
      :with_full_time_sites,
      name: "Primary with english",
      start_date: DateTime.new(current_recruitment_cycle_year, 9, 30),
    )
    @october_course = create(
      :course,
      :with_full_time_sites,
      name: "Spanish",
      start_date: DateTime.new(current_recruitment_cycle_year, 10, 1),
    )
  end

  def when_i_filter_by_september_start_date
    check "September #{current_recruitment_cycle_year}", visible: :all
  end

  def then_i_see_only_courses_starting_in_september
    expect(results).to have_content(@beginning_of_september_course.name)
    expect(results).to have_content(@middle_of_september_course.name)
    expect(results).to have_content(@end_of_september_course.name)

    expect(results).to have_no_content(@january_course.name)
    expect(results).to have_no_content(@august_course.name)
    expect(results).to have_no_content(@october_course.name)
  end

  def then_i_see_only_courses_not_starting_in_september
    expect(results).to have_content(@january_course.name)
    expect(results).to have_content(@august_course.name)
    expect(results).to have_content(@october_course.name)

    expect(results).to have_no_content(@beginning_of_september_course.name)
    expect(results).to have_no_content(@middle_of_september_course.name)
    expect(results).to have_no_content(@end_of_september_course.name)
  end

  def when_i_filter_by_non_september_start_dates
    check "All other dates", visible: :all
  end

  def when_i_filter_by_all_start_date_options
    when_i_filter_by_september_start_date
    when_i_filter_by_non_september_start_dates
  end

  def then_i_see_all_courses_regardless_of_start_date
    expect(results).to have_content(@january_course.name)
    expect(results).to have_content(@august_course.name)
    expect(results).to have_content(@october_course.name)
    expect(results).to have_content(@beginning_of_september_course.name)
    expect(results).to have_content(@middle_of_september_course.name)
    expect(results).to have_content(@end_of_september_course.name)
  end

  def and_i_see_that_six_courses_are_found
    expect(page).to have_content("6 courses found")
    expect(page).to have_title("6 courses found")
  end

  def when_i_search_for_physics_in_subjects_autocomplete
    fill_in "Subject", with: "Physics"
  end

  def and_i_remove_the_subject
    fill_in "Subject", with: ""
    page.find('input[name="subject_name"]').send_keys(:backspace)
  end

  def and_i_select_the_first_subject_suggestion
    page.find('input[name="subject_name"]').native.send_keys(:return)
  end

  def and_i_click_search
    click_link_or_button "Search"
  end

  def then_engineers_teach_physics_filter_is_not_visible
    expect(page).to have_no_content("Only show Engineers teach physics courses")
  end

  def when_i_check_physics
    check "Physics", visible: :all
  end

  def when_i_uncheck_physics
    uncheck "Physics", visible: :all
  end

  def and_physics_and_engineers_teach_physics_courses_are_visible
    expect(page).to have_content(@physics_course.name_and_code)
    expect(page).to have_content(@engineers_teach_physics_course.name_and_code)
    expect(page).to have_no_content(@biology_course.name_and_code)
    expect(page).to have_no_content(@chemistry_course.name_and_code)
    expect(page).to have_no_content(@computing_course.name_and_code)
    expect(page).to have_no_content(@mathematics_course.name_and_code)
  end

  def then_engineers_teach_physics_filter_is_visible
    expect(page).to have_content("Only show Engineers teach physics courses")
  end

  def when_i_check_engineers_teach_physics_only_filter
    check "Only show Engineers teach physics courses", visible: :all
  end

  def and_only_engineers_teach_physics_courses_are_visible
    expect(page).to have_content(@engineers_teach_physics_course.name_and_code)
    expect(page).to have_no_content(@physics_course.name_and_code)
    expect(page).to have_no_content(@biology_course.name_and_code)
    expect(page).to have_no_content(@chemistry_course.name_and_code)
    expect(page).to have_no_content(@computing_course.name_and_code)
    expect(page).to have_no_content(@mathematics_course.name_and_code)
  end

  def and_i_see_that_ten_courses_are_found
    expect(page).to have_content("10 courses found")
    expect(page).to have_title("10 courses found")
  end

private

  def secondary_options
    page.all(
      '[data-filter-search-target="optionsList"]', wait: 2
    ).map(&:text).join(" ").split("\n")
  end

  def results
    page.first(".app-search-results")
  end

  def current_recruitment_cycle_year
    RecruitmentCycle.current.year.to_i
  end
end
