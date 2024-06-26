# frozen_string_literal: true

require 'rails_helper'

feature 'viewing courses in various states' do
  scenario 'viewing a published course' do
    given_there_is_a_published_course
    when_i_visit_the_course_page
    then_i_should_see_the_course
  end

  scenario 'viewing a published with unpublished changes course' do
    given_there_is_a_published_with_unpublished_changes_course
    when_i_visit_the_course_page
    then_i_should_see_the_course
  end

  scenario 'viewing a draft course' do
    given_there_is_a_draft_course
    when_i_visit_the_course_page
    then_i_should_see_page_not_found
  end

  scenario 'viewing a rolled over course' do
    given_there_is_a_rolled_over_course
    when_i_visit_the_course_page
    then_i_should_see_page_not_found
  end

  scenario 'viewing a withdrawn course' do
    given_there_is_a_withdrawn_course
    when_i_visit_the_course_page
    then_i_should_see_page_not_found
  end

  def given_there_is_a_published_course
    @course ||= create(
      :course,
      enrichments: [
        build(
          :course_enrichment,
          :published
        )
      ]
    )
  end

  def when_i_visit_the_find_show_page
    find_results_page.load
  end

  def when_i_visit_the_course_page
    find_course_show_page.load(provider_code: @course.provider.provider_code, course_code: @course.course_code)
  end

  def then_i_should_see_the_course
    expect(page.status_code).to eq(200)
  end

  def then_i_should_see_page_not_found
    expect(page.status_code).to eq(404)
  end

  def given_there_is_a_draft_course
    @course ||= create(
      :course,
      enrichments: [
        build(
          :course_enrichment,
          :draft
        )
      ]
    )
  end

  def given_there_is_a_rolled_over_course
    @course ||= create(
      :course,
      enrichments: [
        build(
          :course_enrichment,
          :rolled_over
        )
      ]
    )
  end

  def given_there_is_a_published_with_unpublished_changes_course
    @course ||= create(
      :course,
      enrichments: [
        build(
          :course_enrichment,
          :subsequent_draft
        )
      ]
    )
  end

  def given_there_is_a_withdrawn_course
    @course ||= create(
      :course,
      enrichments: [
        build(
          :course_enrichment,
          :withdrawn
        )
      ]
    )
  end
end
