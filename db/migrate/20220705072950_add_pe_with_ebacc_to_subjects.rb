class AddPeWithEbaccToSubjects < ActiveRecord::Migration[7.0]
  def up
    Subjects::CreatorService.new.execute
  end

  def down
    # There is no need to go back.
  end
end
