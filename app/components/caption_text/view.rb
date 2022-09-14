# frozen_string_literal: true

module CaptionText
  class View < ViewComponent::Base
    attr_reader :text
    def initialize(text:)
      @text = text
      super
    end
  end
end
