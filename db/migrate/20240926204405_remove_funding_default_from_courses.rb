# frozen_string_literal: true

class RemoveFundingDefaultFromCourses < ActiveRecord::Migration[7.2]
  def change
    change_column_default :course, :funding, from: "not_set", to: nil
  end
end
