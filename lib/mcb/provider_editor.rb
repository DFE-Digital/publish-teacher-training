module MCB
  class ProviderEditor
    attr_reader :provider

    def initialize(provider:, requester:, environment: nil)
      @cli = ProviderCLI.new
      @provider = provider
      @requester = requester
      @environment = environment
      @selected_courses = []

      check_authorisation
    end

    def run
      finished = false
      until finished
        puts MCB::Render::ActiveRecord.provider(provider)
        choice = main_loop

        if choice.nil?
          finished = true
        else
          perform_action(choice)
        end
      end
    end

    def new_provider_wizard
      ask_and_set_provider_details
      ask_and_set_contact_info

      location_name = @cli.ask_name_of_first_location

      ask_and_set_address_info

      puts "\nAbout to create the Provider"
      if @cli.confirm_creation? && try_saving_provider
        organisation = ask_and_set_organisation

        update_organisation_with_admins(organisation)

        create_provider_site(location_name)
        create_next_recruitment_cycle

        puts "New provider has been created: #{provider}"
      else
        puts 'Aborting...'
      end
    end

  private

    def ask_and_set_provider_details
      provider.provider_name = @cli.ask_name
      provider.provider_code = @cli.ask_new_provider_code
      provider.provider_type = @cli.ask_provider_type
    end

    def ask_and_set_contact_info
      contact = @cli.ask_contact
      provider.contact_name = contact[:name]
      provider.email = contact[:email]
      provider.telephone = contact[:telephone]
    end

    def ask_and_set_address_info
      address = @cli.ask_address

      provider.address1 = address[:address1]
      provider.address3 = address[:town_or_city]
      provider.address4 = address[:county]
      provider.postcode = address[:postcode]
      provider.region_code = @cli.ask_region_code
    end

    def try_saving_provider
      if provider.valid?
        puts "Saving the provider"
        provider.save!
        true
      else
        puts "Provider isn't valid:"
        provider.errors.full_messages.each { |error| puts " - #{error}" }
        false
      end
    end

    def ask_and_set_organisation
      organisation = nil

      until organisation.present?
        organisation_name = @cli.ask_organisation_name

        if organisation_name.blank?
          puts "Organisation name cannot be blank."
          next
        end

        organisation = find_or_create_organisation(organisation_name)
      end

      # connect provider to org
      provider.organisations << organisation

      organisation
    end

    def find_or_create_organisation(organisation_name)
      organisation = Organisation.find_or_initialize_by(name: organisation_name)

      if organisation.new_record?
        if @cli.confirm_new_organisation_needed?
          organisation.save!
        else
          organisation = nil
        end
      end

      organisation
    end

    def create_provider_site(location_name)
      provider.sites.create(
        location_name: location_name,
        address1: provider.address1,
        address2: provider.address2,
        address3: provider.address3,
        address4: provider.address4,
        postcode: provider.postcode,
        region_code: provider.region_code
      )
    end

    def create_next_recruitment_cycle
      next_recruitment_cycle = provider.recruitment_cycle.next
      while next_recruitment_cycle
        provider.copy_to_recruitment_cycle(next_recruitment_cycle)
        next_recruitment_cycle = next_recruitment_cycle.next
      end
    end

    # Make sure that the organisation has up-to-date Admin users.
    def update_organisation_with_admins(organisation)
      # Remove Admins if they're already present
      organisation.users << (User.admins - organisation.users)
    end

    def main_loop
      choices = [
        "edit provider name",
        "edit courses",
      ]
      @cli.ask_multiple_choice(prompt: "What would you like to do?", choices: choices)
    end

    def perform_action(choice)
      if choice == "edit provider name"
        edit_provider_name
      elsif choice == "edit courses"
        select_courses_to_edit_and_launch_editor
      end
    end

    def edit_provider_name
      puts "Current name: #{provider.provider_name}"
      update(provider_name: @cli.ask_name)
    end

    def select_courses_to_edit_and_launch_editor
      @selected_courses = @cli.multiselect(
        initial_items: @selected_courses,
        possible_items: @provider.courses.order(:name),
        select_all_option: true,
        hidden_label: ->(course) { course.course_code }
      )
      mcb_courses_edit(@selected_courses.map(&:course_code).sort) unless @selected_courses.empty?
    end

    def mcb_courses_edit(course_codes)
      command_params = ['courses', 'edit', provider.provider_code] + course_codes + environment_options
      $mcb.run(command_params)
    end

    def update(attrs)
      @provider.update(attrs)
    end

    def check_authorisation
      action = @provider.persisted? ? :update? : :create?
      raise Pundit::NotAuthorizedError unless Pundit.policy(@requester, @provider).send(action)
    end

    def environment_options
      @environment.present? ? ['-E', @environment] : []
    end
  end
end
