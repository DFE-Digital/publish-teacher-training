# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard schools step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user_with_multiple_schools
  end

  scenario "choosing a salaried school and continues to study sites page" do
    and_i_have_wizard_state_for_schools(funding_type: "salary")
    when_i_visit_the_wizard_schools_page
    and_the_title_and_description_are_displayed_for_a_salaried_school
    and_i_choose_a_site_from_the_list
    and_i_click_continue
    then_i_am_taken_to_the_study_sites_page
  end

  scenario "choosing a non-salaried school and continues to study sites page" do
    and_i_have_wizard_state_for_schools(funding_type: "fee")
    when_i_visit_the_wizard_schools_page
    and_the_title_and_description_are_displayed_for_a_non_salaried_school
    and_i_choose_a_site_from_the_list
    and_i_click_continue
    then_i_am_taken_to_the_study_sites_page
  end

  scenario "submitting schools without selecting a school shows validation errors" do
    when_i_visit_the_wizard_schools_page
    and_i_click_continue
    then_i_have_errors_on_the_schools_step
  end

  scenario "single-school provider continues to study sites page without explicitly selecting the only school" do
    given_i_am_authenticated_as_a_provider_user_with_a_school
    and_i_have_wizard_state_for_schools(funding_type: "fee")
    when_i_visit_the_wizard_schools_page
    and_i_click_continue
    then_i_am_taken_to_the_study_sites_page
  end

  scenario "TDA qualification route continues through schools step to study sites page" do
    and_i_have_wizard_state_for_qualifications(level: "primary")
    when_i_visit_the_wizard_qualifications_page
    and_i_choose_qualification("Teacher degree apprenticeship (TDA) with QTS")
    and_i_click_continue
    then_i_am_taken_to_the_schools_page
    and_the_title_and_description_are_displayed_for_a_salaried_school
    and_i_choose_a_site_from_the_list
    and_i_click_continue
    then_i_am_taken_to_the_study_sites_page
  end

  scenario "the school address does not repeat the school name" do
    given_i_am_authenticated_as_a_provider_user_with_a_named_school
    and_i_have_wizard_state_for_schools(funding_type: "fee")
    when_i_visit_the_wizard_schools_page
    then_the_school_label_shows_the_name
    and_the_address_is_shown_without_the_school_name
  end

  context "when the provider has more than 20 schools", :js do
    before do
      given_i_am_authenticated_as_a_provider_user_with_25_schools
      and_i_have_wizard_state_for_schools(funding_type: "fee")
      when_i_visit_the_wizard_schools_page
    end

    scenario "the list is collapsed to 20 schools and can be expanded" do
      then_only_the_first_20_schools_are_shown
      when_i_click_show_all_schools
      then_all_the_schools_are_shown
    end

    scenario "a school hidden behind the collapse can still be selected and is saved" do
      then_only_the_first_20_schools_are_shown
      when_i_click_show_all_schools
      and_i_choose_the_last_school_in_the_list
      and_i_click_continue
      then_i_am_taken_to_the_study_sites_page
      and_the_last_school_is_stored_in_the_wizard_state
    end

    scenario "a school already selected beyond the first 20 is collapsed but stays selected" do
      given_the_last_school_is_already_selected_in_the_wizard_state
      when_i_visit_the_wizard_schools_page
      then_only_the_first_20_schools_are_shown
      and_the_last_school_is_hidden_but_still_checked
      and_i_click_continue
      then_i_am_taken_to_the_study_sites_page
      and_the_last_school_is_stored_in_the_wizard_state
    end
  end

private

  def when_i_visit_the_wizard_schools_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :schools,
      state_key: wizard_state_key,
    )
  end

  def when_i_visit_the_wizard_qualifications_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :qualifications,
      state_key: wizard_state_key,
    )
  end

  def and_the_title_and_description_are_displayed_for_a_salaried_school
    expect(page).to have_content("Employing schools")
    expect(page).to have_content("If you do not add all relevant employing schools, you may miss out on potential candidates.")
  end

  def and_the_title_and_description_are_displayed_for_a_non_salaried_school
    expect(page).to have_content("Placement schools")
    expect(page).to have_content("If you do not add all relevant placement schools, you may miss out on potential candidates.")
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def and_i_choose_qualification(qualification)
    choose qualification
  end

  def and_i_choose_a_site_from_the_list
    check provider.sites.first.location_name
  end

  def then_i_have_errors_on_the_schools_step
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select at least one school")
  end

  def then_i_am_taken_to_the_study_sites_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step: :study_sites,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
  end

  def then_i_am_taken_to_the_schools_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step: :schools,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
  end

  def given_i_am_authenticated_as_a_provider_user_with_multiple_schools
    @user = create(
      :user,
      providers: [
        create(
          :provider,
          :accredited_provider,
          sites: [build(:site), build(:site), build(:site, :study_site)],
        ),
      ],
    )

    given_i_am_authenticated(user: @user)
  end

  def given_i_am_authenticated_as_a_provider_user_with_a_school
    @user = create(
      :user,
      providers: [
        create(:provider, :accredited_provider, sites: [build(:site), build(:site, :study_site)]),
      ],
    )

    given_i_am_authenticated(user: @user)
  end

  # Deterministic, non-ambiguous names: the site factory's default is
  # "Main Site#{rand(1_000_000)}", and Capybara's `check` matches label text on a
  # substring, so random names can collide or prefix each other.
  #
  # The study site keeps this provider on the same route as the other scenarios
  # (schools -> study sites). It does not show up in the schools list, since
  # Provider#sites is scoped to school-type sites.
  def given_i_am_authenticated_as_a_provider_user_with_25_schools
    @user = create(
      :user,
      providers: [
        create(
          :provider,
          :accredited_provider,
          sites: (1..25).map { |n| build(:site, location_name: sprintf("School %02d", n)) } + [build(:site, :study_site)],
        ),
      ],
    )

    given_i_am_authenticated(user: @user)
  end

  def given_i_am_authenticated_as_a_provider_user_with_a_named_school
    @user = create(
      :user,
      providers: [
        create(
          :provider,
          :accredited_provider,
          sites: [
            build(
              :site,
              location_name: "Belvidere School",
              address1: "Belvidere Lane",
              address2: "",
              address3: "",
              town: "Shrewsbury",
              address4: "Shropshire",
              postcode: "SY2 5RJ",
            ),
            build(:site),
          ],
        ),
      ],
    )

    given_i_am_authenticated(user: @user)
  end

  def school_checkbox_selector
    "input[name='schools[school_uuids][]']"
  end

  # Counts the visible checkbox rows holding a school checkbox. We check the
  # wrapper's visibility (a block element) rather than the input, because GOV.UK
  # visually hides the real <input> element itself.
  def visible_school_checkbox_count
    page.all(".govuk-checkboxes__item", visible: true).count do |item|
      item.has_css?(school_checkbox_selector, visible: :all)
    end
  end

  def last_school
    @last_school ||= provider.sites.max_by(&:location_name)
  end

  def then_only_the_first_20_schools_are_shown
    # Wait for the Stimulus controller to collapse the list (it reveals the button
    # only after hiding the overflow rows) before the count assertion below, which
    # reads Capybara's synchronous `all` and would otherwise race connect().
    expect(page).to have_button("Show all schools")
    expect(visible_school_checkbox_count).to eq(20)
  end

  def when_i_click_show_all_schools
    click_on "Show all schools"
  end

  def then_all_the_schools_are_shown
    expect(page).to have_no_button("Show all schools")
    expect(visible_school_checkbox_count).to eq(25)
  end

  def and_i_choose_the_last_school_in_the_list
    check last_school.location_name
  end

  def and_the_last_school_is_stored_in_the_wizard_state
    expect(stored_school_uuids).to contain_exactly(last_school.uuid.to_s)
  end

  def given_the_last_school_is_already_selected_in_the_wizard_state
    wizard_state_store.write(school_uuids: [last_school.uuid.to_s])
  end

  # A collapsed school keeps its checked state in the DOM even though its row is
  # hidden, so the selection is not visible but is not dropped either.
  def and_the_last_school_is_hidden_but_still_checked
    expect(page).to have_no_css(".govuk-checkboxes__label", text: last_school.location_name)
    expect(page.find(:checkbox, last_school.location_name, visible: :all)).to be_checked
  end

  def then_the_school_label_shows_the_name
    expect(page).to have_css(".govuk-checkboxes__label", text: "Belvidere School")
  end

  def and_the_address_is_shown_without_the_school_name
    hint = page.find(".govuk-hint", text: "Belvidere Lane")

    expect(hint.text).to eq("Belvidere Lane, Shrewsbury, Shropshire, SY2 5RJ")
    expect(hint.text).not_to include("Belvidere School")
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end

  def and_i_have_wizard_state_for_schools(funding_type:)
    wizard_state_store.write(funding_type:)
  end

  def and_i_have_wizard_state_for_qualifications(level:)
    wizard_state_store.write(level:)
  end

  # Built fresh on each call so reads see state written by the browser, rather
  # than a stale snapshot from when the repository was first constructed.
  def wizard_state_repository
    CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )
  end

  def wizard_state_store
    CourseWizard::StateStores::CourseWizardStore.new(repository: wizard_state_repository)
  end

  # Read straight off the repository: the state store only exposes step attributes
  # through a wizard, which we do not have here.
  def stored_school_uuids
    state = wizard_state_repository.read

    Array(state[:school_uuids] || state["school_uuids"]).compact_blank
  end
end
