# frozen_string_literal: true

class TabNavigation < ApplicationComponent
  attr_reader :items

  def initialize(items:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)
    @items = items
  end
end
