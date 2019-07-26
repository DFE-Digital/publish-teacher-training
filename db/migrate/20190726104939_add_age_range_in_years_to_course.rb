class AddAgeRangeInYearsToCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :course, :age_range_in_years, :string
  end
end
