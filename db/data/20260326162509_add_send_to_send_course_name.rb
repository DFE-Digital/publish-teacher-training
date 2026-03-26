# frozen_string_literal: true

class AddSendToSendCourseName < ActiveRecord::Migration[8.1]
  def up
    Course.with_recruitment_cycle(2026).with_send.where.not("name ~ 'SEND'").find_each do |course|
      course.update_column(:name, course.generate_name)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
