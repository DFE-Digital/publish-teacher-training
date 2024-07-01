# frozen_string_literal: true

require 'rails_helper'

feature 'Adding A levels to a teacher degree apprenticeship course', :can_edit_current_and_next_cycles do
  scenario 'adding a level requirements' do
    given_i_am_authenticated_as_a_provider_user
    and_the_tda_feature_flag_is_active
    and_i_have_a_teacher_degree_apprenticeship_course

    when_i_visit_the_course_description_tab
    then_i_see_a_levels_row

    when_i_click_to_add_a_level_requirements
    then_i_am_on_the_a_levels_required_for_the_course_page
    and_the_back_link_points_to_description_tab

    when_i_click_continue
    then_i_see_an_error_message_for_the_a_levels_required_for_the_course_page

    when_i_choose_no
    and_i_click_continue
    then_i_am_on_the_course_description_tab
    and_i_see_a_levels_is_no_required

    when_i_click_to_change_a_level_requirements
    then_i_am_on_the_a_levels_required_for_the_course_page
    and_the_no_option_is_chosen

    when_i_choose_yes
    and_i_click_continue
    then_i_am_on_the_what_a_level_is_required_page

    when_i_click_back
    then_the_yes_option_is_chosen
    and_i_click_continue

    and_i_click_continue
    then_i_see_an_error_message_for_the_what_a_levels_is_required_for_the_course_page

    when_i_choose_other_subject
    and_i_click_continue
    then_i_see_an_error_message_for_the_what_a_levels_is_required_for_the_course_page

    when_i_choose_any_subject
    and_i_add_a_minimum_grade_required
    and_i_click_continue

    then_i_see_the_subject_i_choosen
    and_i_am_on_the_add_another_a_level_subject_page
    and_i_see_the_success_message_that_i_added_an_a_level

    when_i_click_continue
    then_i_see_an_error_message_for_the_add_a_level_to_a_list_page
    and_i_see_the_subject_i_choosen

    when_i_choose_yes
    and_i_click_continue
    then_i_am_on_the_what_a_level_is_required_page

    when_i_choose_any_stem_subject
    and_i_add_a_minimum_grade_required
    and_i_click_continue
    then_i_see_the_two_subjects_i_already_added

    when_i_choose_yes
    and_i_click_continue
    then_i_am_on_the_what_a_level_is_required_page
    when_i_choose_any_humanities_subject
    and_i_click_continue
    then_i_see_the_three_subjects_i_already_added

    when_i_choose_yes
    and_i_click_continue
    then_i_am_on_the_what_a_level_is_required_page

    when_i_choose_other_subject
    and_i_select_mathematics
    and_i_click_continue
    then_i_see_the_four_subjects_i_already_added
    and_i_do_not_see_the_option_to_add_more_a_level_subjects

    when_i_click_back
    then_i_am_on_the_a_levels_required_for_the_course_page
    and_the_back_link_points_to_description_tab
    and_the_yes_option_is_chosen

    when_i_click_continue
    then_i_am_on_the_add_another_a_level_subject_page

    when_i_click_continue
    then_i_am_on_the_consider_pending_a_level_page

    when_i_click_continue
    then_i_see_an_error_message_for_the_consider_pending_a_level_page

    when_i_choose_yes
    and_i_click_continue
    then_i_am_on_a_level_equivalencies_page

    when_i_click_back
    then_the_yes_option_is_chosen_in_pending_a_level

    when_i_choose_no
    and_i_click_continue
    and_i_click_back
    then_the_no_option_is_chosen_in_pending_a_level

    when_i_click_continue
    and_i_click_update_a_levels
    then_i_see_an_error_message_for_the_a_level_equivalencies

    when_i_choose_yes
    and_i_add_too_many_words_into_additional_a_level_equivalencies
    and_i_click_update_a_levels
    then_i_see_an_error_message_for_the_a_level_equivalencies_additional_a_levels_field

    when_i_add_an_additional_a_level_equivalencies
    and_i_click_update_a_levels
    then_i_am_on_the_course_description_tab

    when_i_enter_on_a_level_equivalencies
    then_the_yes_option_is_chosen_in_a_level_equivalencies
    and_i_see_the_additional_a_level_equivalencies_text

    when_i_click_update_a_levels
    then_i_am_on_the_course_description_tab
    and_i_see_the_a_level_requirements_for_the_course

    when_i_click_to_change_a_level_requirements
    and_i_click_continue
    and_i_click_to_change_the_subject
    then_i_am_on_the_what_a_level_is_required_page_editing_the_subject
    and_any_subject_is_chosen
    and_minimum_grade_required_has_a_value

    when_i_choose_any_science_subject
    and_add_any_grade_as_minimum_grade_required
    and_i_click_continue
    then_i_am_on_the_add_another_a_level_subject_page
    and_i_see_the_updated_a_level_subject_requirement

    when_i_click_to_remove_the_a_level_subject
    then_i_am_on_the_confirming_removal_of_a_level_subject

    when_i_click_continue
    then_i_see_an_error_message_for_the_confirming_removal_of_a_level_subject_page

    when_i_choose_yes
    and_i_click_continue
    then_i_am_on_the_add_another_a_level_subject_page
    and_the_subject_requirement_is_deleted

    when_i_click_to_remove_the_a_level_subject
    and_i_choose_no
    and_i_click_continue
    then_i_am_on_the_add_another_a_level_subject_page
    and_the_subject_requirement_is_not_deleted

    when_i_delete_all_subject_requirements
    then_i_am_on_the_course_description_tab
    and_there_are_no_a_level_requirements_for_the_course
  end

  def given_i_am_authenticated_as_a_provider_user
    recruitment_cycle = create(:recruitment_cycle, year: 2025)
    @user = create(:user, providers: [build(:provider, recruitment_cycle:, provider_type: 'lead_school', sites: [build(:site), build(:site)], study_sites: [build(:site, :study_site), build(:site, :study_site)])])
    @provider = @user.providers.first
    create(:provider, :accredited_provider, provider_code: '1BJ')
    @accredited_provider = create(:provider, :accredited_provider, provider_code: '1BJ', recruitment_cycle:)
    @provider.accrediting_provider_enrichments = []
    @provider.accrediting_provider_enrichments << AccreditingProviderEnrichment.new(
      {
        UcasProviderCode: @accredited_provider.provider_code,
        Description: 'description'
      }
    )

    given_i_am_authenticated(user: @user)
  end

  def and_the_tda_feature_flag_is_active
    allow(Settings.features).to receive(:teacher_degree_apprenticeship).and_return(true)
  end

  def and_i_have_a_teacher_degree_apprenticeship_course
    @course = create(:course, :with_teacher_degree_apprenticeship, provider: @provider)
  end

  def when_i_visit_the_course_description_tab
    publish_provider_courses_show_page.load(provider_code: @provider.provider_code, recruitment_cycle_year: 2025, course_code: @course.course_code)
  end

  def then_i_see_a_levels_row
    expect(page).to have_content('A levels and equivalency tests')
  end

  def when_i_click_to_add_a_level_requirements
    click_on 'Enter A levels and equivalency test requirements'
  end

  def then_i_am_on_the_a_levels_required_for_the_course_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_are_any_a_levels_required_for_this_course_path(
        @provider.provider_code,
        2025,
        @course.course_code
      )
    )
  end

  def when_i_click_continue
    click_on 'Continue'
  end
  alias_method :and_i_click_continue, :when_i_click_continue

  def then_i_see_an_error_message_for_the_a_levels_required_for_the_course_page
    expect(page.title).to eq('Error: Are any A levels required for this course? - Publish teacher training courses - GOV.UK')
    expect(page).to have_content('Select if this course requires any A levels').twice
  end

  def when_i_choose_no
    choose 'No'
  end
  alias_method :and_i_choose_no, :when_i_choose_no

  def then_i_am_on_the_course_description_tab
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_path(
        @provider.provider_code,
        2025,
        @course.course_code
      )
    )
  end

  def and_the_back_link_points_to_description_tab
    expect(page.find_link(text: 'Back')[:href]).to eq(
      publish_provider_recruitment_cycle_course_path(
        @provider.provider_code,
        2025,
        @course.course_code
      )
    )
  end

  def and_i_see_a_levels_is_no_required
    expect(page).to have_content('A levels are not required for this course')
  end

  def when_i_choose_yes
    choose 'Yes'
  end
  alias_method :and_i_choose_yes, :when_i_choose_yes

  def when_i_click_to_change_a_level_requirements
    click_on 'Change A levels'
  end

  def and_the_no_option_is_chosen
    expect(page).to have_checked_field('are-any-a-levels-required-for-this-course-answer-no-field')
  end

  def then_i_am_on_the_what_a_level_is_required_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_what_a_level_is_required_path(
        @provider.provider_code,
        2025,
        @course.course_code
      ),
      ignore_query: true
    )
  end

  def when_i_click_back
    click_on 'Back'
  end
  alias_method :and_i_click_back, :when_i_click_back

  def then_the_yes_option_is_chosen
    expect(page).to have_checked_field('are-any-a-levels-required-for-this-course-answer-yes-field')
  end
  alias_method :and_the_yes_option_is_chosen, :then_the_yes_option_is_chosen

  def when_i_choose_other_subject
    choose 'Choose a subject'
  end

  def then_i_see_an_error_message_for_the_what_a_levels_is_required_for_the_course_page
    and_i_see_there_is_a_problem
    expect(page).to have_content('Select a subject').twice
  end

  def when_i_choose_any_subject
    choose 'Any subject'
  end

  def and_i_add_a_minimum_grade_required
    fill_in 'Minimum grade required (optional)', with: 'C'
  end

  def then_i_see_the_subject_i_choosen
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_add_a_level_to_a_list_path(
        @provider.provider_code,
        2025,
        @course.course_code
      ),
      ignore_query: true
    )
    expect(page).to have_content('Any subject - Grade C or above')
  end
  alias_method :and_i_see_the_subject_i_choosen, :then_i_see_the_subject_i_choosen

  def then_i_see_an_error_message_for_the_add_a_level_to_a_list_page
    and_i_see_there_is_a_problem
    expect(page).to have_content('Select if you want to add another A level').twice
  end

  def and_i_see_there_is_a_problem
    expect(page).to have_content('There is a problem')
  end

  def when_i_choose_any_stem_subject
    choose 'Any STEM subject'
  end

  def then_i_see_the_two_subjects_i_already_added
    and_i_see_the_subject_i_choosen
    expect(page).to have_content('Any STEM subject - Grade C or above')
  end

  def when_i_choose_any_humanities_subject
    choose 'Any humanities subject'
  end

  def then_i_see_the_three_subjects_i_already_added
    then_i_see_the_two_subjects_i_already_added
    expect(page).to have_content('Any humanities subject')
  end

  def when_i_choose_other_subject
    choose 'Choose a subject'
  end

  def and_i_select_mathematics
    select 'Mathematics', from: 'Subjects'
  end

  def then_i_see_the_four_subjects_i_already_added
    then_i_see_the_three_subjects_i_already_added
    expect(page).to have_content('Mathematics')
  end

  def and_i_do_not_see_the_option_to_add_more_a_level_subjects
    expect(page).to have_no_content('Do you want to add another A level?')
    expect(page).to have_no_content('Yes')
    expect(page).to have_no_content('No')
  end

  def then_i_am_on_the_add_another_a_level_subject_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_add_a_level_to_a_list_path(
        @provider.provider_code,
        @provider.recruitment_cycle_year,
        @course.course_code
      ),
      ignore_query: true
    )
  end
  alias_method :and_i_am_on_the_add_another_a_level_subject_page, :then_i_am_on_the_add_another_a_level_subject_page

  def and_i_see_the_success_message_that_i_added_an_a_level
    expect(page).to have_content('You have added a required A level')
  end

  def then_i_am_on_the_consider_pending_a_level_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_consider_pending_a_level_path(
        @provider.provider_code,
        @provider.recruitment_cycle_year,
        @course.course_code
      )
    )
  end

  def then_i_see_an_error_message_for_the_consider_pending_a_level_page
    expect(page).to have_content('Select if you will consider candidates with pending A levels').twice
  end

  def then_i_am_on_a_level_equivalencies_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_a_level_equivalencies_path(
        @provider.provider_code,
        @provider.recruitment_cycle_year,
        @course.course_code
      )
    )
  end

  def when_i_click_update_a_levels
    click_on 'Update A levels'
  end
  alias_method :and_i_click_update_a_levels, :when_i_click_update_a_levels

  def then_i_see_an_error_message_for_the_a_level_equivalencies
    expect(page).to have_content('Select if you will consider candidates who need to take equivalency tests').twice
  end

  def then_the_yes_option_is_chosen_in_pending_a_level
    expect(page).to have_checked_field('consider-pending-a-level-pending-a-level-yes-field')
  end

  def then_the_no_option_is_chosen_in_pending_a_level
    expect(page).to have_checked_field('consider-pending-a-level-pending-a-level-no-field')
  end

  def and_i_add_too_many_words_into_additional_a_level_equivalencies
    fill_in 'Details about equivalency tests you offer or accept',
            with: 'words ' * (ALevelSteps::ALevelEquivalencies::MAXIMUM_ADDITIONAL_A_LEVEL_EQUIVALENCY_WORDS + 2)
  end

  def when_i_add_an_additional_a_level_equivalencies
    fill_in 'Details about equivalency tests you offer or accept', with: 'Some additional A level equivalencies text'
  end

  def then_i_see_an_error_message_for_the_a_level_equivalencies_additional_a_levels_field
    expect(page).to have_content('Details about equivalency tests must be 250 words or less. You have 2 words too many')
  end

  def when_i_enter_on_a_level_equivalencies
    visit publish_provider_recruitment_cycle_course_a_levels_a_level_equivalencies_path(
      @provider.provider_code,
      @provider.recruitment_cycle_year,
      @course.course_code
    )
  end

  def then_the_yes_option_is_chosen_in_a_level_equivalencies
    expect(page).to have_checked_field('a-level-equivalencies-accept-a-level-equivalency-yes-field')
  end

  def and_i_see_the_additional_a_level_equivalencies_text
    expect(page.find('textarea').value).to eq('Some additional A level equivalencies text')
  end

  def and_i_see_the_a_level_requirements_for_the_course
    expect(page).to have_content('Any subject - Grade C or above, or equivalent')
    expect(page).to have_content('Any STEM subject - Grade C or above, or equivalent')
    expect(page).to have_content('Any humanities subject, or equivalent')
    expect(page).to have_content('Mathematics, or equivalent')
    expect(page).to have_content('Candidates with pending A levels will not be considered.')
    expect(page).to have_content('Equivalency tests will be considered.')
    expect(page).to have_content('Some additional A level equivalencies text')
  end

  def and_i_click_to_change_the_subject
    click_on('Change', match: :first)
  end

  def and_any_subject_is_chosen
    expect(page).to have_checked_field('what-a-level-is-required-subject-any-subject-field')
  end

  def and_minimum_grade_required_has_a_value
    expect(find_field('Minimum grade required (optional)').value).to eq 'C'
  end

  def when_i_choose_any_science_subject
    choose 'Any science subject'
  end

  def and_add_any_grade_as_minimum_grade_required
    fill_in 'Minimum grade required (optional)', with: 'B'
  end

  def and_i_see_the_updated_a_level_subject_requirement
    and_there_are_only_four_subjects # it should update and not create another one
  end

  def and_there_are_only_four_subjects
    expect(@course.reload.a_level_subject_requirements.size).to be 4
  end

  def when_i_click_to_remove_the_a_level_subject
    click_on 'Remove', match: :first
  end

  def then_i_am_on_the_what_a_level_is_required_page_editing_the_subject
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_what_a_level_is_required_path(
        @provider.provider_code,
        2025,
        @course.course_code,
        uuid: @course.reload.a_level_subject_requirements.first['uuid']
      )
    )
  end

  def then_i_am_on_the_confirming_removal_of_a_level_subject
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_remove_a_level_subject_confirmation_path(
        @provider.provider_code,
        2025,
        @course.course_code,
        uuid: @course.reload.a_level_subject_requirements.first['uuid']
      )
    )
    expect(page).to have_content('Are you sure you want to remove Any science subject?')
  end

  def then_i_see_an_error_message_for_the_confirming_removal_of_a_level_subject_page
    expect(page).to have_content('Select if you want to remove Any science subject')
  end

  def and_the_subject_requirement_is_deleted
    expect(page).to have_no_content('Any science subject')
    expect(@course.reload.a_level_subject_requirements.size).to be 3
  end

  def and_the_subject_requirement_is_not_deleted
    expect(page).to have_content('Any STEM subject')
    expect(page).to have_content('Any humanities subject')
    expect(page).to have_content('Mathematics')
    expect(@course.reload.a_level_subject_requirements.size).to be 3
  end

  def when_i_delete_all_subject_requirements
    3.times do
      when_i_click_to_remove_the_a_level_subject
      and_i_choose_yes
      and_i_click_continue
    end
  end

  def and_there_are_no_a_level_requirements_for_the_course
    expect(@course.reload.a_level_subject_requirements).to be_empty
    expect(@course.accept_pending_a_level).to be_nil
    expect(@course.accept_a_level_equivalency).to be_nil
    expect(@course.additional_a_level_equivalencies).to be_nil

    expect(page).to have_content('A levels and equivalency tests')
    expect(page).to have_content('Enter A levels and equivalency test requirements')
  end
end
