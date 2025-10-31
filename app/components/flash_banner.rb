# frozen_string_literal: true

class FlashBanner < ApplicationComponent
  attr_reader :flash

  FLASH_TYPES = %w[success warning info].freeze

  def initialize(flash:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)
    @flash = flash
  end

  def render?
    flash.any?
  end
end
