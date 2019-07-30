class UpdateStartDateForRolledOverCourses < ActiveRecord::Migration[5.2]
  def up
    Course.connection.update <<~EOSQL
      UPDATE course c SET start_date = start_date + INTERVAL '1 year'
             FROM provider p, recruitment_cycle rc
             WHERE c.provider_id = p.id
                   AND p.recruitment_cycle_id = rc.id
                   AND rc.year = '2020'
    EOSQL
  end

  def down
    Course.connection.update <<~EOSQL
      UPDATE course c SET start_date = start_date - INTERVAL '1 year'
             FROM provider p, recruitment_cycle rc
             WHERE c.provider_id = p.id
                   AND p.recruitment_cycle_id = rc.id
                   AND rc.year = '2020'
    EOSQL
  end
end
