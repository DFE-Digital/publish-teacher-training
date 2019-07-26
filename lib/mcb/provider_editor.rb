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
      provider.scheme_member = 'Y'
      provider.year_code = provider.recruitment_cycle.year
      provider.last_published_at = Time.zone.now
      provider.changed_at = Time.zone.now

      name = @cli.ask_name
      provider.provider_name = name
      provider.provider_code = @cli.ask_new_provider_code
      provider.provider_type = @cli.ask_provider_type

      provider.scitt = provider.scitt? ? 'Y' : 'N'
      provider.accrediting_provider = if provider.scitt? || provider.university?
                                        :accredited_body
                                      else
                                        :not_an_accredited_body
                                      end

      address = @cli.ask_address
      provider.address1 = address[:address1]
      provider.address2 = address[:address2]
      provider.address3 = address[:town_or_city]
      provider.address4 = address[:county]
      provider.postcode = address[:postcode]
      provider.region_code = @cli.ask_region_code

      contact = @cli.ask_contact
      provider.contact_name = contact[:name]
      provider.email = contact[:email]
      provider.telephone = contact[:telephone]

      provider.url = @cli.ask_url

      provider.save!

      finished_picking_organisation = false
      until finished_picking_organisation
        organisation = Organisation.find_or_initialize_by(name: @cli.ask_organisation_name)
        if organisation.persisted?
          finished_picking_organisation = true
        elsif organisation.new_record? && @cli.confirm_new_organisation_needed?
          organisation.save!
          finished_picking_organisation = true
        end
      end

      # connect provider to org
      provider.organisations << organisation

      # add god users to the org, for any that aren't already in it
      organisation.users << (User.admins - organisation.users)

      next_recruitment_cycle = provider.recruitment_cycle.next
      while next_recruitment_cycle
        provider.copy_to_recruitment_cycle(next_recruitment_cycle)
        next_recruitment_cycle = next_recruitment_cycle.next
      end
    end

  private

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
