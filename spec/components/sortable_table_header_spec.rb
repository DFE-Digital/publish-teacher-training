# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SortableTableHeader, type: :component do
  describe '.direction' do
    it "returns 'descending' when column matches sort and direction is 'ascending'" do
      params = ActionController::Parameters.new(sort: 'course', direction: 'ascending')
      title = "Course #{params[:direction] == 'ascending' ? '(a-z)' : '(z-a)'}"

      sortable_table_header = described_class.new(column: 'course', params:, title:)
      expect(sortable_table_header.direction).to eq('descending')
    end

    it "returns 'descending' when column matches sort and direction is 'descending'" do
      params = ActionController::Parameters.new(sort: 'course', direction: 'descending')
      title = "Course #{params[:direction] == 'ascending' ? '(a-z)' : '(z-a)'}"

      sortable_table_header = described_class.new(column: 'course', params:, title:)
      expect(sortable_table_header.direction).to eq('ascending')
    end

    it "returns 'ascending' when column does not match sort or direction is not 'ascending'" do
      params = ActionController::Parameters.new(sort: 'status', direction: 'descending')

      sortable_table_header = described_class.new(column: 'status', params:, title: "Course #{params[:direction] == 'ascending' ? '(a-z)' : '(z-a)'}")
      expect(sortable_table_header.direction).to eq('ascending')
    end
  end
end
