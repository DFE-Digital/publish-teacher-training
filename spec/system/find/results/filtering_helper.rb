module FilteringHelper
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

  def when_i_visit_the_find_results_page
    visit find_results_path
  end

  def and_the_full_time_filter_is_checked
    expect(page).to have_checked_field("Full time (12 months)", visible: :all)
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

  def then_i_see_only_mathematics_courses
    with_retry do
      expect(results).to have_content("Mathematics (4RTU)")
      expect(results).to have_no_content("Biology")
      expect(results).to have_no_content("Chemistry")
      expect(results).to have_no_content("Computing")
    end
  end

  def and_i_click_search
    click_link_or_button "Search"
  end

  def filtering(filter_name)
    # Find the details section containing this filter
    filter_section = page.find("details", text: filter_name)
    summary = filter_section.find("summary")

    # Open if not already open
    if ActiveModel::Type::Boolean.new.cast(filter_section[:open]).blank?
      summary.click
      sleep 0.1 # Wait for animation
    end

    # Execute the block (choose, select, fill_in, etc.)
    yield
  rescue StandardError
    open_all_details_javascript
    sleep 0.1
    yield
  end

  def open_all_details
    page.all("details").find_each do |details|
      open_details(details)
    end
  end

  def open_all_details_javascript
    page.execute_script(<<~JS)
      document.querySelectorAll('details').forEach(details => {
        details.open = true;
      });
    JS
  end

private

  def results
    page.first(".app-search-results")
  end

  def current_recruitment_cycle_year
    RecruitmentCycle.current.year.to_i
  end
end
