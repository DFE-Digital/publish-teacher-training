# frozen_string_literal: true

require "csv"

namespace :sandbox do
  desc <<~DESC
    Accepts a csv file path of users to be given access to the sandbox environment.
    The file is expected to be in the following format:

    name,email_address,provider
    Dave Test,dave@example.com,Provider name SCITT

    The name will be split first name, last name. Provider name must match exactly with the provider in the API.

    Users will be created if they don't exist already.
    They will then be added to the provider if they aren't associated already.
    Providers are not created, if they don't exist the task will log this and skip the user.
  DESC
  task :import_users, [:csv_file_path] => [:environment] do |_task, args|
    raise "Can only be run in sandbox or development" unless Rails.env.sandbox? || Rails.env.development?

    current_recruitment_cycle = RecruitmentCycle.current

    CSV.foreach(args[:csv_file_path], headers: :first_row, return_headers: false) do |row|
      names = row[0].split
      email = row[1]
      provider_name = row[2]

      first_name = names.shift
      last_name = names.join(" ")

      provider = current_recruitment_cycle.providers.find_by(provider_name:)
      user = User
             .create_with(first_name:, last_name:, accept_terms_date_utc: Time.zone.now)
             .find_or_create_by(email:)

      if provider.blank?
        puts "Provider: #{provider_name} not found. User: #{email} skipped"
        next
      end

      if provider.organisation.users.include?(user)
        puts "User #{email} already belongs to #{provider_name}"
      else
        puts "Adding #{email} to #{provider_name}"
        provider.organisation.users << user
      end
    end
  end

  desc <<~DESC
    Accepts a csv file path of providers to be added to the sandbox environment.
    The file is expected to be in the following format:

    name,code,type,accredited_provider
    Provider one,ABC,scitt,true
    Provider two,DEF,lead_school,false

    provider_type options -> "lead_school", "scitt", "unknown", "university"
    provider_code must be a unique string

    Providers will be created if they don't exist, along with a single
    Organisation and Site per-provider.
  DESC
  task :create_providers, [:csv_file_path] => [:environment] do |_task, args|
    raise "Can only be run in sandbox or development" unless Rails.env.sandbox? || Rails.env.development?

    import = CSVImports::FakeProvidersImport.new(args[:csv_file_path])
    import.execute

    if import.results.any?
      puts import.results.join("\n")
    else
      puts "Nothing was imported"
    end
  end

  desc <<~DESC
    Copies a provider's courses for a recruitment cycle from production, through the
    public Publish API, keeping production's course and site codes. Courses are created
    or updated and published; nothing is deleted.

    The courses the provider accredits for its partners are copied too, under each
    partner. A partner that isn't here is created from production's details, with no
    users or organisation. Running it again changes nothing that already matches.

    It is a dry run unless the third argument is "true":

    bin/rails "sandbox:import_provider_courses[C55,2027]"       # report only, rolls back
    bin/rails "sandbox:import_provider_courses[C55,2027,true]"  # commit
  DESC
  task :import_provider_courses, %i[provider_code year confirm] => [:environment] do |_task, args|
    Sandbox::ImportProviderCourses.call(
      provider_code: args.fetch(:provider_code).upcase,
      year: Integer(args.fetch(:year)),
      confirm: args[:confirm] == "true",
    )
  rescue Sandbox::ImportProviderCourses::Abort => e
    abort e.message
  end
end
