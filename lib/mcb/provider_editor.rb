module MCB
  class ProviderEditor
    attr_reader :provider

    def initialize(provider:, requester:, environment: nil)
      @cli = ProviderCLI.new(provider)
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
      raise Pundit::NotAuthorizedError unless ProviderPolicy.new(@requester, @provider).update?
    end

    def environment_options
      @environment.present? ? ['-E', @environment] : []
    end
  end
end
