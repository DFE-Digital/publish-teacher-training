# frozen_string_literal: true

class RenameAccreditedBodyCodeOnCourses < ActiveRecord::Migration[7.0]
  def change
    rename_column :course, :accredited_body_code, :accredited_provider_code
  end
end
