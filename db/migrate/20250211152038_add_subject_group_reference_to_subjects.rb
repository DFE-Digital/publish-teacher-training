# frozen_string_literal: true

class AddSubjectGroupReferenceToSubjects < ActiveRecord::Migration[8.0]
  def change
    add_reference :subject, :subject_group, foreign_key: true, index: true, null: true
  end
end
