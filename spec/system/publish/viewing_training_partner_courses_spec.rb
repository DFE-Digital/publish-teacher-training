# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Viewing a training partner's courses as an accredited provider" do
  before { given_i_am_authenticated_as_an_accredited_provider_user }

  describe "the View course column" do
    scenario "a live course links through to Find" do
      and_the_partner_has_a_live_course
      when_i_visit_the_training_partner_courses_page

      then_i_should_see_the_column_headings("Course", "Status", "View course")
      expect(course_row("Biology").view_course).to have_link("View live course")
      expect(course_row("Biology").view_course.find("a")[:href])
        .to include("find.localhost/course/#{training_partner.provider_code}/B123")
    end

    scenario "a course with nowhere live to point at has no link" do
      and_the_partner_has_a_live_course
      and_the_partner_has_a_rolled_over_course
      when_i_visit_the_training_partner_courses_page

      expect(course_row("Biology").view_course).to have_link("View live course")
      expect(course_row("Physics").view_course).to have_no_link
      expect(course_row("Physics").status).to have_text("Rolled over")
    end

    scenario "the column is dropped when no course is live" do
      and_the_partner_has_a_rolled_over_course
      when_i_visit_the_training_partner_courses_page

      then_i_should_see_the_column_headings("Course", "Status")
    end
  end

  describe "the Course information column" do
    scenario "shows only the values that vary across the partner's courses" do
      and_the_partner_has_two_courses_differing_only_in_study_mode
      when_i_visit_the_training_partner_courses_page

      then_i_should_see_the_column_headings("Course", "Course information", "Status", "View course")
      expect(course_row("Biology").course_information).to have_text("Full time")
      expect(course_row("Biology").course_information).to have_no_text("Fee-paying")
      expect(course_row("Biology").course_information).to have_no_text("QTS with PGCE")
    end

    scenario "is dropped for a partner with a single course, which cannot vary" do
      and_the_partner_has_a_live_course
      when_i_visit_the_training_partner_courses_page

      then_i_should_see_the_column_headings("Course", "Status", "View course")
    end

    # The comparison must cover the courses this accredited provider ratifies,
    # not everything the partner runs, or a course they cannot see here would
    # decide what they are shown.
    scenario "ignores the partner's courses ratified by someone else" do
      and_the_partner_has_two_courses_differing_only_in_study_mode
      and_the_partner_has_a_part_time_course_ratified_by_another_accredited_provider
      when_i_visit_the_training_partner_courses_page

      expect(rows.size).to eq(2)
      expect(course_row("Biology").course_information).to have_text("Full time")
      expect(course_row("Biology").course_information).to have_no_text("Fee-paying")
    end
  end

  def given_i_am_authenticated_as_an_accredited_provider_user
    given_i_am_authenticated(user: create(:user, providers: [create(:provider, :accredited_provider)]))
    create(:provider_partnership, training_provider: training_partner, accredited_provider: accrediting_provider)
  end

  def and_the_partner_has_a_live_course
    create(
      :course, :published_postgraduate, provider: training_partner, accrediting_provider:,
      name: "Biology", course_code: "B123"
    )
  end

  def and_the_partner_has_a_rolled_over_course
    create(
      :course, :with_full_time_sites, provider: training_partner, accrediting_provider:,
      name: "Physics", course_code: "P456",
      enrichments: [build(:course_enrichment, :rolled_over, course: nil)]
    )
  end

  # Site status vacancies have to agree with the course's study mode, so the
  # part time course composes the traits rather than using
  # :published_postgraduate, which brings full time sites with it.
  def and_the_partner_has_two_courses_differing_only_in_study_mode
    create(:course, :published_postgraduate, provider: training_partner, accrediting_provider:,
                                             name: "Biology", course_code: "B123", study_mode: :full_time)
    create(:course, :open, :with_part_time_sites, :resulting_in_pgce_with_qts,
           provider: training_partner, accrediting_provider:,
           name: "Chemistry", course_code: "C789", study_mode: :part_time)
  end

  def and_the_partner_has_a_part_time_course_ratified_by_another_accredited_provider
    create(
      :course, :published_postgraduate, provider: training_partner,
      accrediting_provider: create(:accredited_provider), name: "Geography", course_code: "G321",
      funding: "salary"
    )
  end

  def when_i_visit_the_training_partner_courses_page
    publish_training_partner_courses_page.load(
      provider_code: accrediting_provider.provider_code,
      recruitment_cycle_year: accrediting_provider.recruitment_cycle_year,
      training_partner_code: training_partner.provider_code,
    )
  end

  def then_i_should_see_the_column_headings(*headings)
    expect(publish_training_partner_courses_page.column_headings.map(&:text)).to eq(headings)
  end

  def rows
    publish_training_partner_courses_page.rows
  end

  def course_row(name)
    rows.find { |row| row.name.text.include?(name) } ||
      raise("no row for #{name.inspect} in #{rows.map { |row| row.name.text }.inspect}")
  end

  def accrediting_provider
    @current_user.providers.first
  end

  def training_partner
    @training_partner ||= create(:provider)
  end
end
