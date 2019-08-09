# == Schema Information
#
# Table name: recruitment_cycle
#
#  id                     :bigint           not null, primary key
#  year                   :string
#  application_start_date :date
#  application_end_date   :date
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

FactoryBot.define do
  factory :recruitment_cycle do
    year { '2019' }
    application_start_date { DateTime.new(year.to_i - 1, 10, 1) }
    application_end_date { DateTime.new(year.to_i, 9, 30) }

    trait :next do
      year { '2020' }
    end
  end
end
