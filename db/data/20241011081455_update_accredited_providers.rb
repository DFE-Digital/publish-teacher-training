# frozen_string_literal: true

class UpdateAccreditedProviders < ActiveRecord::Migration[7.2]
  def up
    # C76 should be the accredited provider for
    # https://www.publish-teacher-training-courses.service.gov.uk/publish/organisations/2DB/2024/courses
    Publish::AccreditedProviderUpdater.new(provider_code: "2DB",
                                           new_accredited_provider_code: "C76",
                                           recruitment_cycle_year: 2024)
                                      .update_provider_and_courses
    Publish::AccreditedProviderUpdater.new(provider_code: "2DB",
                                           new_accredited_provider_code: "C76",
                                           recruitment_cycle_year: 2025)
                                      .update_provider_and_courses

    # https://www.publish-teacher-training-courses.service.gov.uk/publish/organisations/1AV/2024/courses
    # * Whereby C76 is the accredited provider for 2DB and 2DB is the accredited provider for 1AV.
    # TODO: Check that this is what we want to happen
    Publish::AccreditedProviderUpdater.new(provider_code: "1AV",
                                           new_accredited_provider_code: "2DB",
                                           recruitment_cycle_year: 2024)
                                      .update_provider_and_courses
    Publish::AccreditedProviderUpdater.new(provider_code: "1AV",
                                           new_accredited_provider_code: "2DB",
                                           recruitment_cycle_year: 2025)
                                      .update_provider_and_courses

    #   B71 should be the accredited provider for
    # https://www.publish-teacher-training-courses.service.gov.uk/publish/organisations/1SH/2024/courses
    Publish::AccreditedProviderUpdater.new(provider_code: "1SH",
                                           new_accredited_provider_code: "B71",
                                           recruitment_cycle_year: 2024)
                                      .update_provider_and_courses
    Publish::AccreditedProviderUpdater.new(provider_code: "1SH",
                                           new_accredited_provider_code: "B71",
                                           recruitment_cycle_year: 2025)
                                      .update_provider_and_courses

    # B71 should be the accredited provider for
    # https://www.publish-teacher-training-courses.service.gov.uk/publish/organisations/258/2024/courses
    Publish::AccreditedProviderUpdater.new(provider_code: "258",
                                           new_accredited_provider_code: "B71",
                                           recruitment_cycle_year: 2024)
                                      .update_provider_and_courses
    Publish::AccreditedProviderUpdater.new(provider_code: "258",
                                           new_accredited_provider_code: "B71",
                                           recruitment_cycle_year: 2025)
                                      .update_provider_and_courses

    # * 1SH can be deleted
    # TODO

    # 2A5 should be the accredited provider for
    # https://www.publish-teacher-training-courses.service.gov.uk/publish/organisations/1BJ/2024/courses
    Publish::AccreditedProviderUpdater.new(provider_code: "1BJ",
                                           new_accredited_provider_code: "2A5",
                                           recruitment_cycle_year: 2024)
                                      .update_provider_and_courses
    Publish::AccreditedProviderUpdater.new(provider_code: "1BJ",
                                           new_accredited_provider_code: "2A5",
                                           recruitment_cycle_year: 2025)
                                      .update_provider_and_courses

    # 2A5 should be the accredited provider for
    # https://www.publish-teacher-training-courses.service.gov.uk/publish/organisations/24H/2024/courses
    Publish::AccreditedProviderUpdater.new(provider_code: "24H",
                                           new_accredited_provider_code: "2A5",
                                           recruitment_cycle_year: 2024)
                                      .update_provider_and_courses
    Publish::AccreditedProviderUpdater.new(provider_code: "24H",
                                           new_accredited_provider_code: "2A5",
                                           recruitment_cycle_year: 2025)
                                      .update_provider_and_courses

    # 2A5 should be the accredited provider for
    # https://www.publish-teacher-training-courses.service.gov.uk/publish/organisations/5W1/2024/courses
    Publish::AccreditedProviderUpdater.new(provider_code: "5W1",
                                           new_accredited_provider_code: "2A5",
                                           recruitment_cycle_year: 2024)
                                      .update_provider_and_courses
    Publish::AccreditedProviderUpdater.new(provider_code: "5W1",
                                           new_accredited_provider_code: "2A5",
                                           recruitment_cycle_year: 2025)
                                      .update_provider_and_courses

    # 2A5 should be the accredited provider for
    # https://www.publish-teacher-training-courses.service.gov.uk/publish/organisations/3A7/2024/courses
    Publish::AccreditedProviderUpdater.new(provider_code: "3A7",
                                           new_accredited_provider_code: "2A5",
                                           recruitment_cycle_year: 2024)
                                      .update_provider_and_courses
    Publish::AccreditedProviderUpdater.new(provider_code: "3A7",
                                           new_accredited_provider_code: "2A5",
                                           recruitment_cycle_year: 2025)
                                      .update_provider_and_courses
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
