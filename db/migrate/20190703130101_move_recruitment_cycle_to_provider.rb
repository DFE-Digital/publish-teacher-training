require_relative "20190619142449_add_recruitment_cycle_to_course"
require_relative "20190619144634_add_2019_recruitment_cycle_to_courses"
require_relative "20190620060536_set_recruitment_cycle_to_not_null"
require_relative "20190620120944_add_recruitment_cycle_to_site"
require_relative "20190620121519_add_2019_recruitment_cycle_to_sites"
require_relative "20190621125905_set_site_recruitment_cycle_to_not_null"

class MoveRecruitmentCycleToProvider < ActiveRecord::Migration[5.2]
  def up
    add_reference :provider, :recruitment_cycle, index: false, type: :int, foreign_key: true

    current_recruitment_cycle = RecruitmentCycle.where(year: "2019").first

    say_with_time "updating provider recruitment cycle" do
      Provider.connection.update <<~EOSQL
        UPDATE provider SET recruitment_cycle_id=#{current_recruitment_cycle.id}
      EOSQL
    end

    say_with_time "SetSiteRecruitmentCycleToNotNull" do
      revert SetSiteRecruitmentCycleToNotNull
    end
    say_with_time "Add2019RecruitmentCycleToSites" do
      revert Add2019RecruitmentCycleToSites
    end
    say_with_time "AddRecruitmentCycleToSite" do
      revert AddRecruitmentCycleToSite
    end
    say_with_time "SetRecruitmentCycleToNotNull" do
      revert SetRecruitmentCycleToNotNull
    end
    say_with_time "Add2019RecruitmentCycleToCourses" do
      revert Add2019RecruitmentCycleToCourses
    end
    say_with_time "AddRecruitmentCycleToCourse" do
      revert AddRecruitmentCycleToCourse
    end

    change_column_null :provider, :recruitment_cycle_id, false

    remove_index :provider, name: "IX_provider_provider_code"
    add_index    :provider, %i[recruitment_cycle_id provider_code], unique: true
  end

  def down
    add_index    :provider,
                 :provider_code,
                 name: "IX_provider_provider_code",
                 unique: true
    remove_index :provider, %i[recruitment_cycle_id provider_code]

    say_with_time "AddRecruitmentCycleToCourse" do
      run AddRecruitmentCycleToCourse
    end
    say_with_time "Add2019RecruitmentCycleToCourses" do
      run Add2019RecruitmentCycleToCourses
    end
    say_with_time "SetRecruitmentCycleToNotNull" do
      run SetRecruitmentCycleToNotNull
    end
    say_with_time "AddRecruitmentCycleToSite" do
      run AddRecruitmentCycleToSite
    end
    say_with_time "Add2019RecruitmentCycleToSites" do
      run Add2019RecruitmentCycleToSites
    end
    say_with_time "SetSiteRecruitmentCycleToNotNull" do
      run SetSiteRecruitmentCycleToNotNull
    end

    remove_reference :provider, :recruitment_cycle, index: true, foreign_key: true
  end
end
