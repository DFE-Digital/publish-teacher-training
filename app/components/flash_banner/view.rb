# frozen_string_literal: true

module FlashBanner
  class View < GovukComponent::Base
    attr_reader :flash

    FLASH_TYPES = %i[success warning info].freeze

    def initialize(flash:)
      @flash = flash
    end

    def display?
      flash.any?
    end
  end
end
