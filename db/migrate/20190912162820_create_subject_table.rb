# rubocop:todo Rails/CreateTableWithTimestamps
class CreateSubjectTable < ActiveRecord::Migration[5.2]
  def change
    create_table :subject do |t|
      t.text :type
      t.text :subject_code
      t.text :subject_name
    end

    say_with_time "populating subjects" do
      SubjectCreatorService.new.execute
    end
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
