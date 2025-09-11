# frozen_string_literal: true

FactoryBot.define do
  factory :course do
    sequence(:uuid) { |_i| SecureRandom.uuid }
    sequence(:course_code) { |n| "C#{n}#{(0..9).to_a.sample(2).join}" }
    sequence(:name) { |i| "#{Faker::Lorem.word} #{i}" }
    qualification { :pgce_with_qts }
    accrediting_provider { nil }
    with_apprenticeship
    funding { "fee" }

    association :provider

    study_mode { :full_time }
    maths { :must_have_qualification_at_application_time }
    english { :must_have_qualification_at_application_time }
    science { :must_have_qualification_at_application_time }
    level { :primary }
    age_range_in_years { "3_to_7" }
    resulting_in_pgce_with_qts
    start_date { DateTime.new(provider.recruitment_cycle.year.to_i, 9, 1) }
    applications_open_from do
      Faker::Time.between(
        from: provider.recruitment_cycle.application_start_date,
        to: provider.recruitment_cycle.application_end_date,
      )
    end
    degree_grade { :two_one }
    additional_degree_subject_requirements { true }
    degree_subject_requirements { "Completed at least one programming module." }
    is_send { false }

    trait :with_gcse_equivalency do
      accept_pending_gcse { [true, false].sample }
      accept_gcse_equivalency { [true, false].sample }
      accept_english_gcse_equivalency { [true, false].sample }
      accept_maths_gcse_equivalency { [true, false].sample }
      accept_science_gcse_equivalency { [true, false].sample }
      additional_gcse_equivalencies { Faker::Lorem.sentence.to_s }
    end

    trait :with_a_level_requirements do
      a_level_subject_requirements { [{ uuid: SecureRandom.uuid, subject: "any_subject", minimum_grade_required: "A" }] }
      accept_pending_a_level { true }
      accept_a_level_equivalency { true }
      additional_a_level_equivalencies { "Some text" }
    end

    trait :without_validation do
      to_create { |instance| instance.save(validate: false) }
    end

    trait :primary do
      level { :primary }
      age_range_in_years { "3_to_7" }
    end

    trait :secondary do
      age_range_in_years { "11_to_18" }
      level { :secondary }
    end

    transient do
      age { nil }
      infer_level? { false }
      infer_subjects? { true }
    end

    after(:build) do |course, evaluator|
      if evaluator.age.present?
        course.created_at = evaluator.age
        course.updated_at = evaluator.age
        course.changed_at = evaluator.age
      end

      if evaluator.infer_subjects? && course.subjects.empty?
        case course.level
        when "primary"
          course.subjects << find_or_create(:primary_subject, :primary)
        when "secondary"
          course.subjects << find_or_create(:secondary_subject, :drama)
        when "further_education"
          course.subjects << find_or_create(:further_education_subject)
        end
      end

      if evaluator.infer_level? && course.subjects.present?
        subjects = course.subjects
                         .reject { |s| s.type == "DiscontinuedSubject" }
                         .reject { |s| s.type == "MordernLanguagesSubject" }

        if subjects.all? { |subject| subject.type == "PrimarySubject" }
          course.level = "primary"
        elsif subjects.all? { |subject| subject.type == "SecondarySubject" }
          course.level = "secondary"
        elsif subjects.all? { |subject| subject.type == "FurtherEducationSubject" }
          course.level = "further_education"
        end
      end

      course.name = course.generate_name if course.subjects.any? && course.name.blank?
    end

    after(:create) do |course, evaluator|
      # This is important to retain the relationship behaviour between
      # course and it's enrichment
      if evaluator.age.present?
        course.created_at = evaluator.age
        course.updated_at = evaluator.age
        course.changed_at = evaluator.age
      end

      course.name = course.generate_name if course.subjects.any? && course.name.blank?

      course.master_subject_id = course.subjects.first.id if course.subjects.any? && course.master_subject_id.nil?

      # We've just created a course with this provider's code, so ensure it's
      # up-to-date and has this course loaded.
      course.provider.reload
    end

    trait :infer_level do
      transient do
        infer_level? { true }
      end
    end

    trait :dont_infer_subjects do
      transient do
        infer_subjects? { false }
      end
    end

    trait :resulting_in_qts do
      qualification { :qts }
    end

    trait :resulting_in_pgce_with_qts do
      qualification { :pgce_with_qts }
    end

    trait :resulting_in_pgde_with_qts do
      qualification { :pgde_with_qts }
    end

    trait :resulting_in_pgce do
      qualification { :pgce }
    end

    trait :resulting_in_pgde do
      qualification { :pgde }
    end

    trait :resulting_in_undergraduate_degree_with_qts do
      qualification { :undergraduate_degree_with_qts }
    end

    trait :self_accredited do
      association(:provider, factory: %i[provider accredited_provider])
    end

    trait :with_accrediting_provider do
      accrediting_provider { association(:accredited_provider) }

      after(:create) do |course|
        create(:provider_partnership, training_provider: course.provider, accredited_provider: course.accrediting_provider)
      end
    end

    trait :with_higher_education do
      program_type { :higher_education_programme }
      funding { :fee }
    end

    trait :with_school_direct do
      program_type { :school_direct_training_programme }
      funding { :fee }
    end

    trait :with_scitt do
      program_type { :scitt_programme }
      funding { :fee }
    end

    trait :with_apprenticeship do
      program_type { :pg_teaching_apprenticeship }
      funding { :apprenticeship }
    end

    trait :with_teacher_degree_apprenticeship do
      program_type { :teacher_degree_apprenticeship }
      funding { :apprenticeship }
    end

    trait :with_salary do
      program_type { :school_direct_salaried_training_programme }
      funding { :salary }
    end

    trait :fee_type_based do
      program_type do
        %i[higher_education_programme
           school_direct_training_programme
           scitt_programme].sample
      end
      funding { :fee }
    end

    trait :fee do
      funding { "fee" }
    end

    trait :salary do
      funding { "salary" }
    end

    trait :apprenticeship do
      funding { "apprenticeship" }
    end

    trait :salary_type_based do
      program_type { %i[pg_teaching_apprenticeship school_direct_salaried_training_programme].sample }
      funding { :salary }
    end

    trait :non_salary_type_based do
      program_type { %i[scitt_programme higher_education_programme school_direct_training_programme].sample }
    end

    trait :applications_open_from_not_set do
      applications_open_from { nil }
    end

    trait :deleted do
      discarded_at { 1.day.ago }
    end

    trait :skip_validate do
      to_create { |instance| instance.save(validate: false) }
    end

    trait :publishable do
      unpublished
      draft_enrichment
      with_accrediting_provider

      with_gcse_equivalency
    end

    # Assumes a self accredited training provider
    trait :unpublished do
      transient do
        identifier { "unpublished" }
        accredited { false }
      end

      name { "#{identifier} course name" }

      provider do
        if accredited
          find_or_create :accredited_provider, :published_scitt
        else
          find_or_create :provider
        end
      end
      sites { build_list(:site, 1, provider:) }
    end

    trait :with_full_time_sites do
      site_statuses { [build(:site_status, :findable, vac_status: :full_time_vacancies, site: build(:site, latitude: 51.5079, longitude: 0.0877, address1: "1 Foo Street", postcode: "BN1 1AA"))] }
    end

    trait :with_part_time_sites do
      site_statuses { [build(:site_status, :findable, vac_status: :part_time_vacancies, site: build(:site, latitude: 51.5079, longitude: 0.0877, address1: "1 Foo Street", postcode: "BN1 1AA"))] }
    end

    trait :with_full_time_or_part_time_sites do
      site_statuses { [build(:site_status, :findable, vac_status: :both_full_time_and_part_time_vacancies, site: build(:site, latitude: 51.5079, longitude: 0.0877, address1: "1 Foo Street", postcode: "BN1 1AA"))] }
    end

    trait :with_2_full_time_sites do
      site_statuses do
        [
          build(:site_status, :findable, vac_status: :full_time_vacancies, site: build(:site, latitude: 51.5079, longitude: 0.0877, address1: "1 Foo Street", postcode: "BN1 1AA")),
          build(:site_status, :findable, vac_status: :full_time_vacancies, site: build(:site, latitude: 51.5079, longitude: 0.0897, address1: "1 Bar Street", postcode: "BN1 1DD")),
        ]
      end
    end

    trait :draft_enrichment do
      enrichments { [build(:course_enrichment, :initial_draft, course: nil)] }
    end

    trait :published do
      enrichments { [build(:course_enrichment, :published)] }
    end

    trait :withdrawn do
      enrichments { [build(:course_enrichment, :withdrawn)] }
    end

    trait :can_sponsor_skilled_worker_visa do
      can_sponsor_skilled_worker_visa { true }
    end

    trait :can_sponsor_student_visa do
      can_sponsor_student_visa { true }
    end

    trait :can_not_sponsor_visa do
      can_sponsor_student_visa { false }
      can_sponsor_skilled_worker_visa { false }
    end

    trait :engineers_teach_physics do
      campaign_name { :engineers_teach_physics }
    end

    trait :open do
      application_status { :open }
    end

    trait :closed do
      application_status { :closed }
    end

    trait :published_teacher_degree_apprenticeship do
      enrichments do
        [
          build(
            :course_enrichment,
            :published,
            course_length: "4 years",
            fee_uk_eu: nil,
            fee_international: nil,
            required_qualifications: nil,
          ),
        ]
      end
      open
      undergraduate
      with_full_time_sites
      with_teacher_degree_apprenticeship
      resulting_in_undergraduate_degree_with_qts
    end

    trait :published_postgraduate do
      open
      published
      with_full_time_sites
      resulting_in_pgce_with_qts
    end

    trait :with_special_education_needs do
      is_send { true }
    end
  end
end
