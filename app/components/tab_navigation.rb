# frozen_string_literal: true

class TabNavigation < ApplicationComponent
  attr_reader :items

  def initialize(items:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)
    @items = items
  end

  def current_item?(item)
    item == current_item
  end

private

  # A tab marked current: true wins.
  # Otherwise highlight the closest section for this page, so Details is not
  # also active on a page under Schools.
  def current_item
    return @current_item if defined?(@current_item)

    @current_item = items.find { |item| item[:current] } || closest_section
  end

  def closest_section
    items
      .select { |item| section_paths(item).any? { |path| page_under?(path) } }
      .max_by { |item| section_paths(item).map(&:length).max }
  end

  def section_paths(item)
    Array(item[:active_when].presence || item[:url]).map { |path| path.to_s.chomp("/") }
  end

  def page_under?(section_path)
    request.path == section_path || request.path.start_with?("#{section_path}/")
  end
end
