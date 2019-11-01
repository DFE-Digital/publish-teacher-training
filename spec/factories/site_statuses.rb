# == Schema Information
#
# Table name: course_site
#
#  course_id  :integer
#  id         :integer          not null, primary key
#  publish    :text
#  site_id    :integer
#  status     :text
#  vac_status :text
#
# Indexes
#
#  IX_course_site_course_id  (course_id)
#  IX_course_site_site_id    (site_id)
#

FactoryBot.define do
  factory :site_status do
    association :course, study_mode: :full_time
    association(:site)
    publish { "N" }
    vac_status { :full_time_vacancies }
    status { "running" }

    transient do
      any_vancancy { false }
      provider { build :provider }
    end

    trait :published do
      publish { :published }
    end

    trait :unpublished do
      publish { :unpublished }
    end

    trait :part_time_vacancies do
      vac_status { :part_time_vacancies }
    end

    trait :full_time_vacancies do
      vac_status { :full_time_vacancies }
    end

    trait :both_full_time_and_part_time_vacancies do
      vac_status { :both_full_time_and_part_time_vacancies }
    end

    trait :with_any_vacancy do
      any_vancancy { true }
    end

    trait :with_no_vacancies do
      vac_status { :no_vacancies }
    end

    trait :discontinued do
      status { :discontinued }
    end

    trait :running do
      status { :running }
    end

    trait :new do
      status { :new_status }
    end

    trait :suspended do
      status { :suspended }
    end

    trait :findable do
      running
      published
    end

    after(:build) do |site_status, evaluator|
      if evaluator.any_vancancy && site_status&.course&.study_mode.present?
        vac_status = case site_status.course.study_mode
                     when "full_time"
                       :full_time_vacancies
                     when "part_time"
                       :part_time_vacancies
                     when "full_time_or_part_time"
                       :both_full_time_and_part_time_vacancies
                     else
                       :no_vacancies
                     end
        site_status.vac_status = vac_status
      end
    end
  end
end
