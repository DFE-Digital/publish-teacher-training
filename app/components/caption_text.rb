# frozen_string_literal: true

class CaptionText < ViewComponent::Base
  attr_reader :text

  def initialize(text:)
    @text = text
    super
  end
end
