# frozen_string_literal: true

require 'rails_helper'

feature 'Editing visa sponsorship' do
  before do
    given_i_am_authenticated_as_an_admin_user
    and_there_is_a_provider_with_courses
  end

  context 'Editing visa sponsorship' do
    scenario 'fee-paying course' do
      when_i_navigate_to_the_fee_paying_course
      and_the_skilled_worker_visa_question_is_not_rendered
      and_i_see_that_the_student_visa_checkbox_is_not_checked
      and_i_check_the_student_visa_check_box
      and_i_submit_the_form
      and_i_navigate_to_the_same_fee_paying_course
      then_the_student_visa_checkbox_should_be_checked
    end

    scenario 'salaried course' do
      when_i_navigate_to_the_salaried_course
      and_the_student_visa_question_is_not_rendered
      and_i_see_that_the_skilled_worker_visa_checkbox_is_not_checked
      and_i_check_the_skilled_worker_visa_check_box
      and_i_submit_the_form
      and_i_navigate_to_the_same_salaried_course
      then_the_skilled_worker_visa_checkbox_should_be_checked
    end

    scenario 'apprenticeship course' do
      when_i_navigate_to_the_apprenticeship_course
      and_the_student_visa_question_is_not_rendered
      and_i_see_that_the_skilled_worker_visa_checkbox_is_not_checked
      and_i_check_the_skilled_worker_visa_check_box
      and_i_submit_the_form
      and_i_navigate_to_the_same_apprenticeship_course
      then_the_skilled_worker_visa_checkbox_should_be_checked
    end
  end

  def and_i_submit_the_form
    click_link_or_button 'Update'
  end

  def and_i_check_the_student_visa_check_box
    check('support-edit-course-form-can-sponsor-student-visa-true-field')
  end

  def and_i_check_the_skilled_worker_visa_check_box
    check('support-edit-course-form-can-sponsor-skilled-worker-visa-true-field')
  end

  def and_i_see_that_the_student_visa_checkbox_is_not_checked
    expect(page).to have_unchecked_field('support-edit-course-form-can-sponsor-student-visa-true-field')
  end

  def and_i_see_that_the_skilled_worker_visa_checkbox_is_not_checked
    expect(page).to have_unchecked_field('support-edit-course-form-can-sponsor-skilled-worker-visa-true-field')
  end

  def then_the_student_visa_checkbox_should_be_checked
    expect(page).to have_checked_field('support-edit-course-form-can-sponsor-student-visa-true-field')
  end

  def then_the_skilled_worker_visa_checkbox_should_be_checked
    expect(page).to have_checked_field('support-edit-course-form-can-sponsor-skilled-worker-visa-true-field')
  end

  def and_the_skilled_worker_visa_question_is_not_rendered
    expect(page).to have_no_css('#support-edit-course-form-can-sponsor-skilled-worker-visa-true-field')
  end

  def and_the_student_visa_question_is_not_rendered
    expect(page).to have_no_css('#support-edit-course-form-can-sponsor-student-visa-true-field')
  end

  def given_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def provider
    @provider ||= create(:provider, courses: [build(:course, :fee_type_based, id: 1, can_sponsor_student_visa: false), build(:course, :with_salary, id: 2), build(:course, :with_apprenticeship, id: 3)])
  end

  def and_there_is_a_provider_with_courses
    provider
  end

  def when_i_navigate_to_the_apprenticeship_course
    visit edit_support_recruitment_cycle_provider_course_path(provider_id: provider.id, id: 3, recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  def when_i_navigate_to_the_salaried_course
    visit edit_support_recruitment_cycle_provider_course_path(provider_id: provider.id, id: 2, recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  def when_i_navigate_to_the_fee_paying_course
    visit edit_support_recruitment_cycle_provider_course_path(provider_id: provider.id, id: 1, recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  alias_method :and_i_navigate_to_the_same_fee_paying_course, :when_i_navigate_to_the_fee_paying_course
  alias_method :and_i_navigate_to_the_same_salaried_course, :when_i_navigate_to_the_salaried_course
  alias_method :and_i_navigate_to_the_same_apprenticeship_course, :when_i_navigate_to_the_apprenticeship_course
end
