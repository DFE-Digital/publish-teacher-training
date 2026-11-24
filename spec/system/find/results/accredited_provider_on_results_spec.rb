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

  context "with grouped results" do
    before { FeatureFlag.activate(:group_search_results) }

    scenario "a training partner offers a subject through 2 accredited providers" do
      given_a_training_partner_offers_biology_through_two_accredited_providers
      when_i_search_by_provider("Oakwood Academy")
      then_the_training_partner_has_one_card
      and_each_course_shows_its_own_accredited_provider
    end

    scenario "a training partner offers a subject through 1 accredited provider" do
      given_a_training_partner_offers_biology_twice_through_one_accredited_provider
      when_i_search_by_provider("Oakwood Academy")
      then_the_training_partner_has_one_card
      and_the_accredited_provider_shows_once_in_the_header
    end

    scenario "searching by an accredited provider with 2 training partners" do
      given_an_accredited_provider_with_two_training_partners
      when_i_search_by_provider("Manchester Metropolitan University")
      then_each_training_partner_has_its_own_card_naming_the_accredited_provider
      and_i_do_not_see_it_on_the_accredited_providers_own_card
    end

    scenario "searching by subject when a training partner offers it through 2 accredited providers" do
      given_a_training_partner_offers_biology_through_two_accredited_providers
      when_i_search_for_biology
      then_the_training_partner_has_one_card
      and_each_course_shows_its_own_accredited_provider
    end

    scenario "searching by subject when a training partner offers it through 1 accredited provider" do
      given_a_training_partner_offers_biology_twice_through_one_accredited_provider
      when_i_search_for_biology
      then_the_training_partner_has_one_card
      and_i_do_not_see_an_accredited_provider
    end
  end

  scenario "searching by subject without grouped results" do
    given_a_training_partner_offers_biology_through_two_accredited_providers
    when_i_search_for_biology
    then_i_do_not_see_an_accredited_provider
  end

  def given_an_accredited_provider_with_a_training_partner
    create(:course, :secondary, :published, :open, :with_full_time_sites, provider: mmu, name: "Biology", course_code: "MMU1", subjects: [biology], master_subject_id: biology.id)
    create(:course, :secondary, :published, :open, :with_full_time_sites, provider: oakwood, accredited_provider_code: mmu.provider_code, name: "Biology", course_code: "OAK1", subjects: [biology], master_subject_id: biology.id)
  end

  def given_a_training_partner_offers_biology_through_two_accredited_providers
    create(:course, :secondary, :published, :open, :with_full_time_sites, provider: oakwood, accredited_provider_code: mmu.provider_code, name: "Biology", course_code: "OAK1", subjects: [biology], master_subject_id: biology.id)
    create(:course, :secondary, :published, :open, :with_full_time_sites, provider: oakwood, accredited_provider_code: edge_hill.provider_code, name: "Biology", course_code: "OAK2", subjects: [biology], master_subject_id: biology.id)
  end

  def given_a_training_partner_offers_biology_twice_through_one_accredited_provider
    create(:course, :secondary, :published, :open, :with_full_time_sites, provider: oakwood, accredited_provider_code: mmu.provider_code, name: "Biology", course_code: "OAK1", subjects: [biology], master_subject_id: biology.id)
    create(:course, :secondary, :published, :open, :with_full_time_sites, provider: oakwood, accredited_provider_code: mmu.provider_code, name: "Biology", course_code: "OAK2", subjects: [biology], master_subject_id: biology.id)
  end

  def given_an_accredited_provider_with_two_training_partners
    given_an_accredited_provider_with_a_training_partner
    create(:course, :secondary, :published, :open, :with_full_time_sites, provider: pinewood, accredited_provider_code: mmu.provider_code, name: "Biology", course_code: "PIN1", subjects: [biology], master_subject_id: biology.id)
  end

  def when_i_search_by_provider(provider_name)
    visit find_results_path(provider_name:)
  end

  def when_i_search_for_biology
    visit find_results_path(subjects: [biology.subject_code])
  end

  def then_i_do_not_see_an_accredited_provider
    expect(page).to have_css(".app-search-results__item")
    expect(page).to have_no_content(/accredited by/i)
  end
  alias_method :and_i_do_not_see_an_accredited_provider, :then_i_do_not_see_an_accredited_provider

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

  def then_the_training_partner_has_one_card
    expect(page).to have_css(".app-search-results__item", count: 1)
    expect(page).to have_css(".govuk-summary-card__title", text: "Oakwood Academy", count: 1)
    expect(page).to have_css(".app-search-result__course", count: 2)
  end

  def and_each_course_shows_its_own_accredited_provider
    expect(page).not_to have_css(".govuk-summary-card__title", text: "Accredited by")
    expect(course_on_card("Biology (OAK1)")).to have_content("Ages 11 to 18, accredited by Manchester Metropolitan University")
    expect(course_on_card("Biology (OAK2)")).to have_content("Ages 11 to 18, accredited by Edge Hill University")
  end

  def and_the_accredited_provider_shows_once_in_the_header
    within(".app-search-results__item") do
      expect(page).to have_css(".govuk-summary-card__title", text: "Oakwood Academy Accredited by Manchester Metropolitan University")
      expect(page).to have_content(/accredited by/i, count: 1)
    end
  end

  def then_each_training_partner_has_its_own_card_naming_the_accredited_provider
    expect(page).to have_css(".app-search-results__item", count: 3)
    expect(page).to have_css(".govuk-summary-card__title", text: "Oakwood Academy Accredited by Manchester Metropolitan University", count: 1)
    expect(page).to have_css(".govuk-summary-card__title", text: "Pinewood School Accredited by Manchester Metropolitan University", count: 1)
  end

  def and_i_do_not_see_it_on_the_accredited_providers_own_card
    within(result_card("Biology (MMU1)")) do
      expect(page).not_to have_content("Accredited by")
    end
  end

  def course_on_card(course_name_and_code)
    page.find(".app-search-result__course", text: course_name_and_code)
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

  def pinewood
    @pinewood ||= create(:provider, provider_name: "Pinewood School")
  end

  def biology
    @biology ||= find_or_create(:secondary_subject, :biology)
  end
end
