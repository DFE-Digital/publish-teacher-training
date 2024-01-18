# frozen_string_literal: true

require 'rails_helper'

feature 'Guidance components on course edit page', { can_edit_current_and_next_cycles: false } do
  describe 'university providers' do
    context 'when provider is excluded via config' do
      scenario 'Guidance is not shown' do
        given_a_provider_which_does_not_show_guidance
        and_the_provider_has_a_course
        and_i_am_authenticated_as_a_provider_user
        when_i_go_to_edit_a_course
        i_do_not_see_the_guidance_text
      end

      def given_a_provider_which_does_not_show_guidance
        @provider = create(:provider, :university, provider_code: 'B31')
      end
    end

    context 'when provider is not excluded via config' do
      scenario 'Guidance is shown' do
        given_a_provider_which_does_show_guidance
        and_the_provider_has_a_course
        and_i_am_authenticated_as_a_provider_user
        when_i_go_to_edit_a_course
        i_do_see_the_guidance_text
      end

      def given_a_provider_which_does_show_guidance
        @provider = create(:provider, :university, provider_code: 'XXX')
      end
    end
  end

  describe 'scitt courses' do
    context 'when provider is excluded via config' do
      scenario 'Guidance is not shown' do
        given_a_provider_which_does_not_show_guidance
        and_the_provider_has_a_course
        and_i_am_authenticated_as_a_provider_user
        when_i_go_to_edit_a_course
        i_do_not_see_the_guidance_text
      end

      def given_a_provider_which_does_not_show_guidance
        @provider = create(:provider, :scitt, provider_code: 'E65')
      end
    end

    context 'when provider is not excluded via config' do
      scenario 'Guidance is shown' do
        given_a_provider_which_does_show_guidance
        and_the_provider_has_a_course
        and_i_am_authenticated_as_a_provider_user
        when_i_go_to_edit_a_course
        i_do_see_the_guidance_text
      end

      def and_the_provider_has_a_course
        @course = create(:course, :with_scitt, provider: @provider)
      end

      def given_a_provider_which_does_show_guidance
        @provider = create(:provider, :scitt, provider_code: 'T92')
      end
    end
  end

  def and_the_provider_has_a_course
    @course = create(:course, provider: @provider)
  end

  def and_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated
    @current_user.providers << @provider
  end

  def when_i_go_to_edit_a_course
    publish_course_information_edit_page.load(
      provider_code: @provider.provider_code, recruitment_cycle_year: @provider.recruitment_cycle_year, course_code: @course.course_code
    )
  end

  def i_do_not_see_the_guidance_text
    expect(page).to have_no_content('Where you will train')
  end

  def i_do_see_the_guidance_text
    expect(page).to have_content('Where you will train')
  end
end
