# frozen_string_literal: true

module FeatureHelpers
  module ConfirmLiveChanges
    def and_i_confirm_publishing_live_changes
      expect(page).to have_content(I18n.t("publish.courses.confirm_live_changes.body"))
      click_button I18n.t("publish.courses.confirm_live_changes.continue")
    end

    def then_i_should_not_see_the_live_changes_interstitial
      expect(page).to have_no_content(I18n.t("publish.courses.confirm_live_changes.body"))
      expect(page).to have_no_button(I18n.t("publish.courses.confirm_live_changes.continue"))
    end
  end
end
