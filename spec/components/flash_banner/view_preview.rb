# frozen_string_literal: true

module FlashBanner
  class ViewPreview < ViewComponent::Preview
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

    def flash(type)
      flash = ActionDispatch::Flash::FlashHash.new
      flash[type] = "Provider #{type}"
      flash
    end
  end
end
