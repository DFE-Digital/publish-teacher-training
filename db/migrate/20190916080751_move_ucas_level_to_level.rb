class MoveUCASLevelToLevel < ActiveRecord::Migration[5.2]
  def up
    Course.find_each do |course|
      course.level = course.ucas_level
      course.save!
    end
  end

  def down
    Course.find_each do |course|
      course.level = nil
      course.save!
    end
  end
end
