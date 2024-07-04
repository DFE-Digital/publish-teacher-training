# frozen_string_literal: true

class SortableTableHeaderPreview < ViewComponent::Preview
  def course_ascending
    render(SortableTableHeader.new(column: 'course', title: 'Course (a-z)', params: ActionController::Parameters.new(sort: 'course', direction: 'ascending')))
  end

  def course_descending
    render(SortableTableHeader.new(column: 'course', title: 'Course (z-a)', params: ActionController::Parameters.new(sort: 'course', direction: 'descending')))
  end

  def course_status
    render(SortableTableHeader.new(column: 'status', title: 'Status', params: ActionController::Parameters.new(sort: 'course', direction: 'descending')))
  end
end
