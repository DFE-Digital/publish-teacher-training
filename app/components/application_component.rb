# frozen_string_literal: true

class ApplicationComponent < GovukComponent::Base
  def initialize(classes: [], html_attributes: {})
    super
  end

  private

  def default_attributes
    {}
  end
end
