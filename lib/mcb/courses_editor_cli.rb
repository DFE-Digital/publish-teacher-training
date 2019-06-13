module MCB
  class CoursesEditorCLI
    def initialize(provider)
      @cli = HighLine.new
      @provider = provider
    end

    def main_loop
      @cli.choose do |menu|
        menu.choice("exit")
        menu.choices(
          "edit title",
          "edit maths",
          "edit english",
          "edit science",
          "edit route",
          "edit qualifications",
          "edit study mode",
          "edit accredited body",
          "edit start date",
          "edit application opening date",
        )
        menu.choice("sync course(s) to Find")
      end
    end

    def ask_title
      @cli.ask("New course title?  ")
    end

    def ask_english; ask_gcse_subject(:english); end

    def ask_maths; ask_gcse_subject(:maths); end

    def ask_science; ask_gcse_subject(:science); end

    def ask_gcse_subject(subject)
      ask_multiple_choice(
        prompt: "What's the #{subject} entry requirements?",
        choices: Course::ENTRY_REQUIREMENT_OPTIONS.keys
      )
    end

    def ask_route
      ask_multiple_choice(
        prompt: "What's the route?",
        choices: Course.program_types.keys
      )
    end

    def ask_qualifications
      ask_multiple_choice(
        prompt: "What's the course outcome?",
        choices: Course.qualifications.keys,
        default: "pgce_with_qts"
      )
    end

    def ask_study_mode
      ask_multiple_choice(
        prompt: "Full time or part time?",
        choices: Course.study_modes.keys,
        default: "full_time"
      )
    end

    def ask_accredited_body
      new_accredited_body = nil
      until new_accredited_body.present?
        begin
          new_accredited_body = ask_accredited_body_once
        rescue ActiveRecord::RecordNotFound
          puts "Can't find accredited body; please enter one that exists."
        end
      end
      new_accredited_body
    end

    def ask_accredited_body_once
      code = @cli.ask "Provider code of accredited body (leave blank if self-accredited)  ", ->(str) { str.upcase }
      code.present? ? Provider.find_by!(provider_code: code) : @provider
    end

    def ask_start_date
      Date.parse(@cli.ask("Start date?  ") { |q| q.default = "September #{Course::DEFAULT_RECRUITMENT_CYCLE_YEAR}" })
    end

    def ask_application_opening_date
      Date.parse(@cli.ask("Applications opening date?  ") { |q| q.default = Date.today.to_s })
    end

  private

    def ask_multiple_choice(prompt:, choices:, default: nil)
      @cli.choose do |menu|
        menu.prompt = prompt + "  "
        menu.choice("exit") { nil }
        menu.choices(*choices)
        menu.default = default if default.present?
      end
    end
  end
end
