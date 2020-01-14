class CreateSubjectArea < ActiveRecord::Migration[6.0]
  def change
    create_table :subject_area, primary_key: :typename, id: false do |t|
      t.text :typename, null: false # This ID will be tied to subject types
      t.text :name
      t.timestamps
    end

    change_table :subject do |t|
      t.references :subject_area
    end

    say_with_time "populating subject areas" do
      Subjects::SubjectAreaCreatorService.new.execute
    end
  end
end
