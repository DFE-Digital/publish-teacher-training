# frozen_string_literal: true

class SortableTableHeader < ViewComponent::Base
  attr_reader :column, :params, :title

  def initialize(column:, params:, title:)
    super
    @column = column
    @params = params
    @title = title
  end

  def direction
    column == params[:sort] && params[:direction] == 'ascending' ? 'descending' : 'ascending'
  end

  def full_title
    "#{title} #{column_title_suffix(column)}"
  end

  private

  def column_title_suffix(column)
    if column == 'course'
      direction == 'descending' ? '(z-a)' : '(a-z)'
    else
      ''
    end
  end
end
