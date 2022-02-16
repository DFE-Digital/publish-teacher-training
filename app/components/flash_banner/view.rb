# frozen_string_literal: true

module FlashBanner
  class View < GovukComponent::Base
    attr_reader :flash

    FLASH_TYPES = %w[success warning info].freeze

    def initialize(flash:)
      super(classes: classes, html_attributes: html_attributes)
      @flash = flash
    end

    def display?
      flash.any?
    end
  end
end
