# frozen_string_literal: true

module FlashBanner
  class View < ApplicationComponent
    attr_reader :flash

    FLASH_TYPES = %w[success warning info].freeze

    def initialize(flash:, classes: [], html_attributes: {})
      super(classes:, html_attributes:)
      @flash = flash
    end

    def display?
      flash.any?
    end
  end
end
