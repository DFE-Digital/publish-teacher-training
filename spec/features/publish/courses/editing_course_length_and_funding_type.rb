# frozen_string_literal: true

require "rails_helper"

feature "Editing course length and funding type" do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  context "fee based" do
    scenario "i can update the course length and fee" do
      and_there_is_a_course_i_want_to_edit(:fee_type_based)
      when_i_visit_the_course_fee_page
      and_i_update_the_length_and_fee
      and_i_submit_the(publish_course_fee_page)
      then_i_should_see_a_success_message
      and_the_course_fee_is_updated
    end

    scenario "copying course information with no courses available" do
      and_there_is_a_course_i_want_to_edit(:fee_type_based)
      when_i_visit_the_course_fee_page
      then_i_should_see_the_reuse_content
    end

    context "copying content from another course" do
      let!(:course2) do
        create(
          :course,
          provider: provider,
          name: "Biology",
          enrichments: [course2_enrichment],
        )
      end

      let!(:course3) do
        create :course,
               provider: provider,
               name: "Biology",
               enrichments: [course3_enrichment]
      end

      let(:course2_enrichment) do
        build(:course_enrichment,
              course_length: "OneYear",
              fee_uk_eu: "8000",
              fee_international: "20000",
              fee_details: "Test fee details",
              financial_support: "Test financial support")
      end

      let(:course3_enrichment) do
        build(:course_enrichment,
              course_length: "5 years",
              fee_uk_eu: "",
              fee_international: "",
              fee_details: "",
              financial_support: "")
      end

      scenario "all fields get copied if all are present" do
        and_there_is_a_course_i_want_to_edit(:fee_type_based)
        when_i_visit_the_course_fee_page
        publish_course_fee_page.copy_content.copy(course2)

        [
          "Your changes are not yet saved",
          "Course length",
          "Fee for UK students",
          "Fee for international students",
          "Fee details",
          "Financial support",
        ].each do |name|
          expect(publish_course_fee_page.copy_content_warning).to have_content(name)
        end

        expect(publish_course_fee_page.course_length.one_year).to be_checked
        expect(publish_course_fee_page.course_length.upto_two_years).not_to be_checked
        expect(publish_course_fee_page.course_length.other).not_to be_checked
        # the below test hangs locally
        expect(publish_course_fee_page.course_length.other_text).to be_blank
        expect(publish_course_fee_page.uk_fee.value).to eq(course2_enrichment.fee_uk_eu.to_s)
        expect(publish_course_fee_page.international_fee.value).to eq(course2_enrichment.fee_international.to_s)
        expect(publish_course_fee_page.financial_support.value).to eq(course2_enrichment.financial_support)
      end

      scenario "with custom course length and all other fields empty" do
        and_there_is_a_course_i_want_to_edit(:fee_type_based)
        when_i_visit_the_course_fee_page
        publish_course_fee_page.copy_content.copy(course3)

        [
          "Your changes are not yet saved",
          "Course length",
        ].each do |name|
          expect(publish_course_fee_page.copy_content_warning).to have_content(name)
        end

        [
          "Fee for UK students",
          "Fee for international students",
          "Fee details",
          "Financial support",
        ].each do |name|
          expect(publish_course_fee_page.copy_content_warning).not_to have_content(name)
        end

        expect(publish_course_fee_page.course_length.one_year).not_to be_checked
        expect(publish_course_fee_page.course_length.upto_two_years).not_to be_checked
        expect(publish_course_fee_page.course_length.other).to be_checked
        # the below test hangs locally
        expect(publish_course_fee_page.course_length.other_text).to eq(course3_enrichment.course_length)
      end
    end

    scenario "updating with invalid data" do
      and_there_is_a_course_i_want_to_edit(:fee_type_based)
      when_i_visit_the_course_fee_page
      and_i_set_an_incorrect_fee_amount
      and_i_submit_the(publish_course_fee_page)
      then_i_should_see_an_error_message_for_the_course_fee
    end
  end

  context "salary based" do
    scenario "i can update the course length and salary details" do
      and_there_is_a_course_i_want_to_edit(:salary_type_based)
      when_i_visit_the_course_salary_page
      and_i_update_the_length_and_salary_details
      and_i_submit_the(publish_course_salary_page)
      then_i_should_see_a_success_message
      and_the_course_salary_is_updated
    end

    scenario "updating with invalid data" do
      and_there_is_a_course_i_want_to_edit(:salary_type_based)
      when_i_visit_the_course_salary_page
      and_i_set_incorrect_salary_information
      and_i_submit_the(publish_course_salary_page)
      then_i_should_see_an_error_message_for_the_course_salary_details
    end
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit(type)
    given_a_course_exists(type, enrichments: [build(:course_enrichment, :published, course_length: "OneYear")])
  end

  def when_i_visit_the_course_fee_page
    publish_course_fee_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def when_i_visit_the_course_salary_page
    publish_course_salary_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def then_i_should_see_the_reuse_content
    expect(publish_course_fee_page).to have_use_content
  end

  def and_i_update_the_length_and_fee
    @new_uk_fee = 10_000

    publish_course_fee_page.course_length.upto_two_years.choose
    publish_course_fee_page.uk_fee.set(@new_uk_fee)
  end

  def and_i_update_the_length_and_salary_details
    @new_salary_details = "new salary details"

    publish_course_salary_page.course_length.upto_two_years.choose
    publish_course_salary_page.salary_details.set(@new_salary_details)
  end

  def and_i_set_an_incorrect_fee_amount
    publish_course_fee_page.uk_fee.set(120_000)
  end

  def and_i_set_incorrect_salary_information
    publish_course_salary_page.salary_details.set(nil)
  end

  def and_i_submit_the(form_page)
    form_page.submit.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content(I18n.t("success.saved"))
  end

  def and_the_course_fee_is_updated
    enrichment = course.reload.enrichments.find_or_initialize_draft

    expect(enrichment.course_length).to eq("TwoYears")
    expect(enrichment.fee_uk_eu).to eq(@new_uk_fee)
  end

  def and_the_course_salary_is_updated
    enrichment = course.reload.enrichments.find_or_initialize_draft

    expect(enrichment.course_length).to eq("TwoYears")
    expect(enrichment.salary_details).to eq(@new_salary_details)
  end

  def then_i_should_see_an_error_message_for_the_course_fee
    expect(publish_course_fee_page.error_messages).to include(
      I18n.t("activemodel.errors.models.publish/course_fee_form.attributes.fee_uk_eu.less_than_or_equal_to"),
    )
  end

  def then_i_should_see_an_error_message_for_the_course_salary_details
    expect(publish_course_salary_page.error_messages).to include(
      I18n.t("activemodel.errors.models.publish/course_salary_form.attributes.salary_details.blank"),
    )
  end

  def provider
    @current_user.providers.first
  end
end
