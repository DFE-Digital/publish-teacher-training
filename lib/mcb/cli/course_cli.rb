module MCB
  module Cli
    class CourseCli < MCB::Cli::BaseCli
      def initialize(provider)
        super()
        @provider = provider
      end

      def ask_title
        @cli.ask("New course title?  ")
      end

      def ask_level
        ask_multiple_choice(
          prompt: "What level is this course?",
          choices: Course.levels.keys,
        )
      end

      def ask_english
        ask_gcse_subject(:english, Course::entry_requirement_options_without_nil_choice)
      end

      def ask_maths
        ask_gcse_subject(:maths, Course::entry_requirement_options_without_nil_choice)
      end

      def ask_science
        ask_gcse_subject(:science, Course::ENTRY_REQUIREMENT_OPTIONS.keys)
      end

      def ask_gcse_subject(subject, choices)
        ask_multiple_choice(
          prompt: "What's the #{subject} entry requirements?",
          choices: choices,
        )
      end

      def ask_route
        ask_multiple_choice(
          prompt: "What's the route?",
          choices: Course.program_types.keys,
        )
      end

      def ask_qualifications
        ask_multiple_choice(
          prompt: "What's the course outcome?",
          choices: Course.qualifications.keys,
          default: "pgce_with_qts",
        )
      end

      def ask_study_mode
        ask_multiple_choice(
          prompt: "Full time or part time?",
          choices: Course.study_modes.keys,
          default: "full_time",
        )
      end

      def ask_age_range
        ask_multiple_choice(
          prompt: "Age range?",
          choices: Course.age_ranges.keys,
        )
      end

      def ask_is_send
        @cli.agree("Is the course SEND?   ")
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
        Date.parse(@cli.ask("Start date?  ") { |q| q.default = "September #{Settings.current_recruitment_cycle_year}" })
      end

      def ask_application_opening_date
        Date.parse(@cli.ask("Applications opening date?  ") { |q| q.default = Time.zone.today.to_s })
      end

      def ask_course_code
        @cli.ask("Course code?  ", ->(str) { str.upcase }) do |q|
          q.whitespace = :strip_and_collapse
          q.validate = /\S+/
        end
      end
    end
  end
end
