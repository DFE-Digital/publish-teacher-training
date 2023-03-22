# frozen_string_literal: true

module CoursePreview
  class MissingInformationComponent < ViewComponent::Base
    attr_accessor :text, :link

    def initialize(text, link)
      super
      @text = text
      @link = link
    end
  end
end
