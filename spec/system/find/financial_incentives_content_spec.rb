# frozen_string_literal: true

require "rails_helper"

RSpec.describe "financial incentives call out boxes content" do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    FeatureFlag.activate(:bursaries_and_scholarships_announced)
  end

  context "UK citizens" do
    context "given a future financial incentive exists but is hidden" do
      scenario "search results render the displayed financial incentive for UK citizens" do
        given_there_is_a_findable_course(bursary_amount: 4000, scholarship_amount: 2000)
        and_there_is_a_hidden_future_financial_incentive(non_uk_bursary_eligible: true, non_uk_scholarship_eligible: true)
        when_i_visit_the_find_results_page
        then_i_see_the_displayed_search_result_financial_incentive_is_for_uk_citizens
        and_i_do_not_see_the_hidden_future_financial_incentive
      end

      scenario "the course page renders the displayed financial incentive for UK citizens" do
        given_there_is_a_findable_course(bursary_amount: 4000, scholarship_amount: 2000)
        and_there_is_a_hidden_future_financial_incentive(non_uk_bursary_eligible: true, non_uk_scholarship_eligible: true)
        when_i_visit_the_find_results_page
        when_i_select_the_course
        then_i_see_the_displayed_course_page_financial_incentive_is_for_uk_citizens
        and_i_do_not_see_the_hidden_future_financial_incentive
      end

      scenario "search results render the displayed financial incentive when it is available to non-UK citizens" do
        given_there_is_a_findable_course(bursary_amount: 4000, scholarship_amount: 2000, subject: :physics, non_uk_bursary_eligible: true, non_uk_scholarship_eligible: true)
        and_there_is_a_hidden_future_financial_incentive
        when_i_visit_the_find_results_page
        then_i_see_the_displayed_search_result_financial_incentive_is_available_to_non_uk_citizens
        and_i_do_not_see_the_hidden_future_financial_incentive
      end

      scenario "the course page renders the displayed financial incentive when it is available to non-UK citizens" do
        given_there_is_a_findable_course(bursary_amount: 4000, scholarship_amount: 2000, subject: :physics, non_uk_bursary_eligible: true, non_uk_scholarship_eligible: true)
        and_there_is_a_hidden_future_financial_incentive
        when_i_visit_the_find_results_page
        when_i_select_the_course
        then_i_see_the_displayed_course_page_financial_incentive_is_available_to_non_uk_citizens
        and_i_do_not_see_the_hidden_future_financial_incentive
      end
    end

    context "given the course has bursary and scholarship available" do
      scenario "renders the bursary and scholarship content" do
        given_there_is_a_findable_course(bursary_amount: 4000, scholarship_amount: 2000)
        when_i_visit_the_find_results_page
        when_i_select_the_course
        then_i_see_bursary_and_scholarship_content_for_uk_citizens
      end
    end

    context "given the course only has bursaries available" do
      scenario "renders the bursaries content" do
        given_there_is_a_findable_course(bursary_amount: 4000)
        when_i_visit_the_find_results_page
        when_i_select_the_course
        then_i_see_bursary_content_for_uk_citizens
      end
    end

    context "given the course has NO bursary or scholarship available" do
      scenario "renders the non bursary and scholarship content" do
        given_there_is_a_findable_course
        when_i_visit_the_find_results_page
        when_i_select_the_course
        then_i_see_student_loans_content_for_uk_citizens
      end
    end

    context "given the course is salaried" do
      scenario "renders the salaried content for QTS with PGCE" do
        given_there_is_a_findable_course(funding: "salary")
        when_i_visit_the_find_results_page
        when_i_select_the_course
        then_i_see_salaried_content_for_uk_citizens_with_pgce
      end

      scenario "renders the salaried content for QTS only" do
        given_there_is_a_findable_course(funding: "salary", qualification: "qts")
        when_i_visit_the_find_results_page
        when_i_select_the_course
        then_i_see_salaried_content_for_uk_citizens
      end
    end
  end

  context "Non-UK citizens" do
    context "given the course has bursary and scholarship available" do
      scenario "renders the bursary and scholarship content" do
        given_there_is_a_findable_course(bursary_amount: 4000, scholarship_amount: 2000, subject: :physics, non_uk_bursary_eligible: true, non_uk_scholarship_eligible: true)
        when_i_visit_the_find_results_page
        when_i_select_the_course
        then_i_see_bursary_and_scholarship_content_for_non_uk_citizens
      end
    end

    context "given the course has bursaries available" do
      scenario "renders the bursaries content" do
        given_there_is_a_findable_course(bursary_amount: 4000, subject: :ancient_hebrew, non_uk_bursary_eligible: true)
        when_i_visit_the_find_results_page
        when_i_select_the_course
        then_i_see_bursary_content_for_non_uk_citizens
      end
    end

    context "given the course has NO bursary and scholarship available" do
      scenario "renders the non bursary and scholarship content" do
        given_there_is_a_findable_course
        when_i_visit_the_find_results_page
        when_i_select_the_course
        then_i_see_no_bursary_or_scholarship_content_for_non_uk_citizens
      end
    end

    context "given the course is salaried" do
      scenario "renders the salaried content" do
        given_there_is_a_findable_course(funding: "salary")
        when_i_visit_the_find_results_page
        when_i_select_the_course
        then_i_see_salaried_content_for_non_uk_citizens
      end
    end
  end

  def when_i_visit_the_find_results_page
    find_results_page.load
  end

  def within_financial_support_for_uk_citizens(&block)
    within(".govuk-accordion", text: "Financial support for UK citizens", &block)
  end

  def within_financial_support_for_non_uk_citizens(&block)
    within(".govuk-accordion", text: "Financial support for non-UK citizens", &block)
  end

  def within_salaried_content_for_uk_citizens(&block)
    within(".govuk-accordion", text: "How salaried courses work", &block)
  end

  def within_salaried_content_for_non_uk_citizens(&block)
    within(".govuk-accordion", text: "Non-UK citizens: applying for salaried courses", &block)
  end

  def then_i_see_bursary_and_scholarship_content_for_uk_citizens
    within_financial_support_for_uk_citizens do
      expect(page).to have_content("Bursaries of £4,000 and scholarships of £2,000 are available to eligible trainees.")
    end
  end

  def then_i_see_bursary_content_for_uk_citizens
    within_financial_support_for_uk_citizens do
      expect(page).to have_content("Bursaries of £4,000 are available to eligible trainees.")
    end
  end

  def then_i_see_student_loans_content_for_uk_citizens
    within_financial_support_for_uk_citizens do
      expect(page).to have_content("You may be eligible for student loans to cover the cost of your tuition fee or to help with living costs.")
    end
  end

  def then_i_see_salaried_content_for_uk_citizens_with_pgce
    within_salaried_content_for_uk_citizens do
      expect(page).to have_content("You will receive an unqualified teacher’s salary while training. The exact amount will vary depending on your school. You may also have to pay for your PGCE. You can discuss salary details with the provider at interview.")
    end
  end

  def then_i_see_salaried_content_for_uk_citizens
    within_salaried_content_for_uk_citizens do
      expect(page).to have_content("You will receive an unqualified teacher’s salary while training. The exact amount will vary depending on your school. You can discuss salary details with the provider at interview.")
    end
  end

  def then_i_see_bursary_and_scholarship_content_for_non_uk_citizens
    within_financial_support_for_non_uk_citizens do
      expect(page).to have_content("Bursaries of £4,000 and scholarships of £2,000 are available to eligible trainees.")
    end
  end

  def then_i_see_bursary_content_for_non_uk_citizens
    within_financial_support_for_non_uk_citizens do
      expect(page).to have_content("Bursaries of £4,000 are available to eligible trainees.")
    end
  end

  def then_i_see_no_bursary_or_scholarship_content_for_non_uk_citizens
    within_financial_support_for_non_uk_citizens do
      expect(page).to have_content("If you are a non-UK citizen without indefinite leave to remain you are unlikely to be eligible for a bursary, scholarship or student loan")
      expect(page).to have_content("Find out what financial support is available to non-UK citizens.")
    end
  end

  def then_i_see_salaried_content_for_non_uk_citizens
    within_salaried_content_for_non_uk_citizens do
      expect(page).to have_content("You can apply for a salaried teacher training course. However, these courses are limited in number and very competitive.")
      expect(page).to have_content("Before you apply, contact the teacher training provider to check you meet the entry requirements.")
    end
  end

  def then_i_see_the_displayed_search_result_financial_incentive_is_for_uk_citizens
    expect(page).to have_content("Scholarships of £2,000 or bursaries of £4,000 are available for UK citizens")
  end

  def then_i_see_the_displayed_search_result_financial_incentive_is_available_to_non_uk_citizens
    expect(page).to have_content("Scholarships of £2,000 or bursaries of £4,000 are available")
    expect(page).to have_no_content("Scholarships of £2,000 or bursaries of £4,000 are available for UK citizens")
  end

  def then_i_see_the_displayed_course_page_financial_incentive_is_for_uk_citizens
    expect(page).to have_content("Scholarships of £2,000 or bursaries of £4,000 are available for UK citizens")
    expect(page).to have_content("Bursaries of £4,000 and scholarships of £2,000 are available to eligible trainees.")
  end

  def then_i_see_the_displayed_course_page_financial_incentive_is_available_to_non_uk_citizens
    expect(page).to have_content("Scholarships of £2,000 or bursaries of £4,000 are available")
    expect(page).to have_no_content("Scholarships of £2,000 or bursaries of £4,000 are available for UK citizens")
    expect(page).to have_content("Bursaries of £4,000 and scholarships of £2,000 are available to eligible trainees.")
  end

  def and_i_do_not_see_the_hidden_future_financial_incentive
    expect(page).to have_no_content("£99,999")
    expect(page).to have_no_content("£88,888")
  end

  def and_there_is_a_hidden_future_financial_incentive(non_uk_bursary_eligible: false, non_uk_scholarship_eligible: false)
    create(
      :financial_incentive,
      :hidden,
      subject: @course.subjects.first,
      year: FinancialIncentive.current_year + 1,
      bursary_amount: 99_999,
      scholarship: 88_888,
      non_uk_bursary_eligible:,
      non_uk_scholarship_eligible:,
    )
  end

  def given_there_is_a_findable_course(bursary_amount: nil, scholarship_amount: nil, funding: "fee", qualification: "pgce_with_qts", subject: :chemistry, non_uk_bursary_eligible: false, non_uk_scholarship_eligible: false)
    @course = create(
      :course,
      :secondary,
      :with_scitt,
      funding:,
      qualification:,
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
          non_uk_bursary_eligible: non_uk_bursary_eligible,
          non_uk_scholarship_eligible: non_uk_scholarship_eligible,
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
    expect(page).to have_current_path(
      find_course_path(provider_code: @course.provider_code, course_code: @course.course_code),
      ignore_query: true,
    )
  end

  alias_method :when_i_select_the_course, :select_course
end
