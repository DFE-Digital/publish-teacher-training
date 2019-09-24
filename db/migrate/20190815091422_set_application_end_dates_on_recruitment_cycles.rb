class SetApplicationEndDatesOnRecruitmentCycles < ActiveRecord::Migration[5.2]
  def up
    say_with_time "fixing recruitment cycles with a nil application end dates" do
      RecruitmentCycle.all.each do |recruitment_cycle|
        recruitment_cycle.update(application_end_date: DateTime.new(recruitment_cycle.year.to_i, 9, 30)) if recruitment_cycle.application_end_date.nil?
      end
    end
  end
end
