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
      names = row[0].split(" ")
      email = row[1]
      provider_name = row[2]

      first_name = names.shift
      last_name = names.join(" ")

      provider = current_recruitment_cycle.providers.find_by(provider_name: provider_name)
      user = User
        .create_with(first_name: first_name, last_name: last_name, accept_terms_date_utc: Time.zone.now.utc)
        .find_or_create_by!(email: email)

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

    name,code,type,accredited_body
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
end
