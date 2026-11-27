# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Search results show the age range when it tells courses apart", service: :find do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_providers_with_maths_and_primary_courses
  end

  context "with grouped results" do
    before { FeatureFlag.activate(:group_search_results) }

    scenario "searching for courses" do
      when_i_visit_the_results_page
      then_a_card_whose_secondary_courses_share_an_age_range_does_not_show_it
      and_a_card_whose_secondary_courses_have_different_age_ranges_shows_each
      and_a_secondary_course_on_its_own_card_does_not_show_it
      and_primary_courses_always_show_it
    end
  end

  scenario "searching for courses without grouped results" do
    when_i_visit_the_results_page
    then_every_course_shows_its_age_range
  end

  def given_providers_with_maths_and_primary_courses
    create_course(provider: bishop_challoner, course_code: "B001", age_range_in_years: "11_to_16")
    create_course(provider: bishop_challoner, course_code: "B002", age_range_in_years: "11_to_16")
    create_course(provider: active_teacher_training, course_code: "A236", age_range_in_years: "11_to_16")
    create_course(provider: active_teacher_training, course_code: "U736", age_range_in_years: "11_to_18")
    create_course(provider: solo_scitt, course_code: "S001", age_range_in_years: "11_to_18")
    create_course(provider: red_kite, course_code: "R001", age_range_in_years: "5_to_11", level: :primary, subject: primary)
    create_course(provider: red_kite, course_code: "R002", age_range_in_years: "5_to_11", level: :primary, subject: primary)
  end

  def when_i_visit_the_results_page
    visit find_results_path
  end

  def then_a_card_whose_secondary_courses_share_an_age_range_does_not_show_it
    expect(result_card("Bishop Challoner")).to have_css(".app-search-result__course", count: 2)
    expect(result_card("Bishop Challoner")).to have_no_content("Ages")
  end

  def and_a_card_whose_secondary_courses_have_different_age_ranges_shows_each
    expect(course_on_card("Mathematics (A236)")).to have_css("p.govuk-hint", exact_text: "Ages 11 to 16")
    expect(course_on_card("Mathematics (U736)")).to have_css("p.govuk-hint", exact_text: "Ages 11 to 18")
  end

  def and_a_secondary_course_on_its_own_card_does_not_show_it
    expect(result_card("Solo SCITT")).to have_no_content("Ages")
  end

  def and_primary_courses_always_show_it
    expect(course_on_card("Primary (R001)")).to have_css("p.govuk-hint", exact_text: "Ages 5 to 11")
    expect(course_on_card("Primary (R002)")).to have_css("p.govuk-hint", exact_text: "Ages 5 to 11")
  end

  def then_every_course_shows_its_age_range
    expect(result_card("Mathematics (B001)")).to have_css("p.govuk-hint", exact_text: "Ages 11 to 16")
    expect(result_card("Mathematics (B002)")).to have_css("p.govuk-hint", exact_text: "Ages 11 to 16")
    expect(result_card("Mathematics (S001)")).to have_css("p.govuk-hint", exact_text: "Ages 11 to 18")
  end

  def create_course(provider:, course_code:, age_range_in_years:, level: :secondary, subject: mathematics)
    create(
      :course,
      level,
      :published,
      :open,
      :with_full_time_sites,
      provider:,
      course_code:,
      age_range_in_years:,
      name: subject.subject_name,
      subjects: [subject],
      master_subject_id: subject.id,
    )
  end

  def result_card(text)
    page.find(".app-search-results__item", text:)
  end

  def course_on_card(course_name_and_code)
    page.find(".app-search-result__course", text: course_name_and_code)
  end

  def bishop_challoner
    @bishop_challoner ||= create(:provider, provider_name: "Bishop Challoner")
  end

  def active_teacher_training
    @active_teacher_training ||= create(:provider, provider_name: "Active Teacher Training")
  end

  def solo_scitt
    @solo_scitt ||= create(:provider, provider_name: "Solo SCITT")
  end

  def red_kite
    @red_kite ||= create(:provider, provider_name: "Red Kite Teacher Training")
  end

  def mathematics
    @mathematics ||= find_or_create(:secondary_subject, :mathematics)
  end

  def primary
    @primary ||= find_or_create(:primary_subject, :primary)
  end
end
