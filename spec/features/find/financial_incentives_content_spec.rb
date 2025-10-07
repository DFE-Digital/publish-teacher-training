# frozen_string_literal: true

require "rails_helper"

feature "financial incentives call out boxes content" do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    FeatureFlag.activate(:bursaries_and_scholarships_announced)
  end

  context "UK citizens" do
    context "given the course has bursary and scholarship available" do
      scenario "renders the bursary and scholarship content" do
        given_there_is_a_findable_course(bursary_amount: 4000, scholarship_amount: 2000)
        when_i_visit_the_find_results_page
        select_course

        within('[data-qa="course__scholarship_and_bursary_details"]') do
          expect(page).to have_content("Bursaries of £4,000 and scholarships of £2,000 are available to eligible trainees.")
        end
      end
    end

    context "given the course only has bursaries available" do
      scenario "renders the bursaries content" do
        given_there_is_a_findable_course(bursary_amount: 4000)
        when_i_visit_the_find_results_page
        select_course

        within('[data-qa="course__bursary_details"]') do
          expect(page).to have_content("Bursaries of £4,000 are available to eligible trainees.")
        end
      end
    end

    context "given the course has NO bursary or scholarship available" do
      scenario "renders the non bursary and scholarship content" do
        given_there_is_a_findable_course
        when_i_visit_the_find_results_page
        select_course

        within('[data-qa="course__loan_details"]') do
          expect(page).to have_content("You may be eligible for student loans to cover the cost of your tuition fee or to help with living costs.")
        end
      end
    end

    context "given the course is salaried" do
      scenario "renders the salaried content" do
        given_there_is_a_findable_course(funding: "salary")
        when_i_visit_the_find_results_page
        select_course

        within('[data-qa="course__salary_details"]') do
          expect(page).to have_content("You will be paid a salary during this course. Financial support such as bursaries, scholarships and student loans is not available.")
        end
      end
    end
  end

  context "Non-UK citizens" do
    context "given the course has bursary and scholarship available" do
      scenario "renders the bursary and scholarship content" do
        given_there_is_a_findable_course(bursary_amount: 4000, scholarship_amount: 2000, subject: :physics)
        when_i_visit_the_find_results_page
        select_course

        within('[data-qa="course__scholarship_and_bursary_details_non_uk"]') do
          expect(page).to have_content("Bursaries of £4,000 and scholarships of £2,000 are available to eligible trainees.")
        end
      end
    end

    context "given the course has bursaries available" do
      scenario "renders the bursaries content" do
        given_there_is_a_findable_course(bursary_amount: 4000, subject: :ancient_hebrew)
        when_i_visit_the_find_results_page
        select_course

        within('[data-qa="course__bursary_details_non_uk"]') do
          expect(page).to have_content("Bursaries of £4,000 are available to eligible trainees.")
        end
      end
    end

    context "given the course has NO bursary and scholarship available" do
      scenario "renders the non bursary and scholarship content" do
        given_there_is_a_findable_course
        when_i_visit_the_find_results_page
        select_course

        within('[data-qa="course__loan_details_non_uk"]') do
          expect(page).to have_content("If you are a non-UK citizen without indefinite leave to remain you are unlikely to be eligible for a bursary, scholarship or student loan\nFind out what financial support is available to non-UK citizens.")
        end
      end
    end

    context "given the course is salaried" do
      scenario "renders the salaried content" do
        given_there_is_a_findable_course(funding: "salary")
        when_i_visit_the_find_results_page
        select_course

        within('[data-qa="course__salary_details_non_uk"]') do
          expect(page).to have_content("You can apply for a salaried teacher training course. However, these courses are limited in number and very competitive.")
          expect(page).to have_content("Before you apply, contact the teacher training provider to check you meet the entry requirements.")
        end
      end
    end
  end

  def when_i_visit_the_find_results_page
    find_results_page.load
  end

  def given_there_is_a_findable_course(bursary_amount: nil, scholarship_amount: nil, funding: "fee", subject: :chemistry)
    @course = create(
      :course,
      :secondary,
      :with_scitt,
      funding:,
      provider:,
      accrediting_provider:,
      site_statuses: [build(:site_status, :full_time_vacancies, :findable)],
      enrichments: [build(:course_enrichment, :published)],
      subjects: [
        build(
          :secondary_subject,
          subject,
          scholarship: scholarship_amount,
          bursary_amount: bursary_amount,
        ),
      ],
    )
  end

  def provider
    @provider = create(
      :provider,
      :scitt,
      provider_name: "Provider 1",
      accredited_partnerships: [build(:provider_partnership, accredited_provider: accrediting_provider)],
    )
  end

  def accrediting_provider
    @accrediting_provider ||= create(
      :provider,
      :accredited_provider,
      provider_name: "Accrediting Provider 1",
    )
  end

  def select_course
    click_on(@course.name)
  end
end
