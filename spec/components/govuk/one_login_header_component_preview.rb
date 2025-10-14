# frozen_string_literal: true

module Govuk
  class OneLoginHeaderComponentPreview < ViewComponent::Preview
    def signed_out
      render(Govuk::OneLoginHeaderComponent.new(current_user: nil))
    end

    def signed_in
      render(Govuk::OneLoginHeaderComponent.new(current_user: FactoryBot.build_stubbed(:candidate)))
    end
  end
end
