# frozen_string_literal: true

class AddNoteToSavedCourse < ActiveRecord::Migration[8.0]
  def change
    add_column :saved_course, :note, :text
  end
end
