class FixSubjectAreaNameCases < ActiveRecord::Migration[6.0]
  def up
    say_with_time "fixing the subject areas naming case" do
      SubjectArea.where(name: "Secondary: Modern Languages").update(name: "Secondary: Modern languages")
      SubjectArea.where(name: "Further Education").update(name: "Further education")
    end
  end
end
