# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Search results show the accredited provider when searching by provider", service: :find do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  scenario "searching by an accredited provider" do
    given_an_accredited_provider_with_a_training_partner
    when_i_search_by_provider("Manchester Metropolitan University")
    then_i_see_the_accredited_provider_under_the_training_partner_name
    and_i_do_not_see_it_on_the_accredited_providers_own_course
  end

  scenario "searching by a training partner that offers the same subject through different accredited providers" do
    given_a_training_partner_offers_biology_through_two_accredited_providers
    when_i_search_by_provider("Oakwood Academy")
    then_i_see_the_accredited_provider_under_each_course_name
  end

  scenario "searching by a training partner that offers different subjects through different accredited providers" do
    given_a_training_partner_offers_biology_and_physics_through_different_accredited_providers
    when_i_search_by_provider("Oakwood Academy")
    then_i_see_the_accredited_provider_under_the_training_partner_name_on_each_card
  end

  scenario "not searching by provider" do
    given_an_accredited_provider_with_a_training_partner
    when_i_visit_the_results_page
    then_i_do_not_see_any_accredited_provider
  end

  def given_an_accredited_provider_with_a_training_partner
    create(:course, :secondary, :published, :open, :with_full_time_sites, provider: mmu, name: "Biology", course_code: "MMU1", subjects: [biology], master_subject_id: biology.id)
    create(:course, :secondary, :published, :open, :with_full_time_sites, provider: oakwood, accredited_provider_code: mmu.provider_code, name: "Biology", course_code: "OAK1", subjects: [biology], master_subject_id: biology.id)
  end

  def given_a_training_partner_offers_biology_through_two_accredited_providers
    create(:course, :secondary, :published, :open, :with_full_time_sites, provider: oakwood, accredited_provider_code: mmu.provider_code, name: "Biology", course_code: "OAK1", subjects: [biology], master_subject_id: biology.id)
    create(:course, :secondary, :published, :open, :with_full_time_sites, provider: oakwood, accredited_provider_code: edge_hill.provider_code, name: "Biology", course_code: "OAK2", subjects: [biology], master_subject_id: biology.id)
  end

  def given_a_training_partner_offers_biology_and_physics_through_different_accredited_providers
    create(:course, :secondary, :published, :open, :with_full_time_sites, provider: oakwood, accredited_provider_code: mmu.provider_code, name: "Biology", course_code: "OAK1", subjects: [biology], master_subject_id: biology.id)
    create(:course, :secondary, :published, :open, :with_full_time_sites, provider: oakwood, accredited_provider_code: edge_hill.provider_code, name: "Physics", course_code: "OAK2", subjects: [physics], master_subject_id: physics.id)
  end

  def when_i_search_by_provider(provider_name)
    visit find_results_path(provider_name:)
  end

  def when_i_visit_the_results_page
    visit find_results_path
  end

  def then_i_see_the_accredited_provider_under_the_training_partner_name
    within(result_card("Biology (OAK1)")) do
      expect(page).to have_css(".govuk-summary-card__title", text: "Oakwood Academy Accredited by Manchester Metropolitan University")
    end
  end

  def and_i_do_not_see_it_on_the_accredited_providers_own_course
    within(result_card("Biology (MMU1)")) do
      expect(page).not_to have_content("Accredited by")
    end
  end

  def then_i_see_the_accredited_provider_under_each_course_name
    within(result_card("Biology (OAK1)")) do
      expect(page).to have_css(".govuk-summary-card__content", text: "Ages 11 to 18, accredited by Manchester Metropolitan University")
      expect(page).not_to have_css(".govuk-summary-card__title", text: "Accredited by")
    end
    within(result_card("Biology (OAK2)")) do
      expect(page).to have_css(".govuk-summary-card__content", text: "Ages 11 to 18, accredited by Edge Hill University")
      expect(page).not_to have_css(".govuk-summary-card__title", text: "Accredited by")
    end
  end

  def then_i_see_the_accredited_provider_under_the_training_partner_name_on_each_card
    within(result_card("Biology (OAK1)")) do
      expect(page).to have_css(".govuk-summary-card__title", text: "Accredited by Manchester Metropolitan University")
    end
    within(result_card("Physics (OAK2)")) do
      expect(page).to have_css(".govuk-summary-card__title", text: "Accredited by Edge Hill University")
    end
  end

  def then_i_do_not_see_any_accredited_provider
    expect(page).to have_content("Biology (OAK1)")
    expect(page).not_to have_content("Accredited by")
    expect(page).not_to have_content("accredited by")
  end

  def result_card(course_name_and_code)
    page.find(".app-search-results__item", text: course_name_and_code)
  end

  def mmu
    @mmu ||= create(:provider, :accredited_provider, provider_name: "Manchester Metropolitan University")
  end

  def edge_hill
    @edge_hill ||= create(:provider, :accredited_provider, provider_name: "Edge Hill University")
  end

  def oakwood
    @oakwood ||= create(:provider, provider_name: "Oakwood Academy")
  end

  def biology
    @biology ||= find_or_create(:secondary_subject, :biology)
  end

  def physics
    @physics ||= find_or_create(:secondary_subject, :physics)
  end
end
