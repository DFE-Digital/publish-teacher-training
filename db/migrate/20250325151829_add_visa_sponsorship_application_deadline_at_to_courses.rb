# frozen_string_literal: true

class AddVisaSponsorshipApplicationDeadlineAtToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :course, :visa_sponsorship_application_deadline_at, :datetime
  end
end
