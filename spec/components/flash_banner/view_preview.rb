# frozen_string_literal: true

module FlashBanner
  class ViewPreview < ViewComponent::Preview
    def with_error
      render(FlashBanner::View.new(flash: flash(:error, flash_value: { id: "some-id", message: "some message" }.with_indifferent_access)))
    end

    def with_success_with_body
      render(FlashBanner::View.new(flash: flash(:success_with_body, flash_value: { title: "some title", body: "some body" }.with_indifferent_access)))
    end

    def with_success
      render(FlashBanner::View.new(flash: flash(:success)))
    end

    def with_warning
      render(FlashBanner::View.new(flash: flash(:warning)))
    end

    def with_info
      render(FlashBanner::View.new(flash: flash(:info)))
    end

  private

    def flash(type, flash_value: "Provider #{type}")
      flash = ActionDispatch::Flash::FlashHash.new
      flash[type] = flash_value
      flash
    end
  end
end
