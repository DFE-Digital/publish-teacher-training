# frozen_string_literal: true

module FeatureHelpers
  module ConfirmLiveChanges
    def and_i_confirm_publishing_live_changes
      expect(page).to have_content("Your changes will go live immediately.")
      click_button "Continue and publish changes"
    end

    def then_i_should_not_see_the_live_changes_interstitial
      expect(page).to have_no_content("Your changes will go live immediately.")
      expect(page).to have_no_button("Continue and publish changes")
    end
  end
end
