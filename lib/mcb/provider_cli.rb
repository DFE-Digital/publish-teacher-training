module MCB
  class ProviderCLI < BaseCLI
    def initialize(provider)
      super()

      @provider = provider
    end

    def ask_name
      @cli.ask("Enter new name").strip
    end

    def ask_new_course_code
      @cli.ask("New course code?  ")
    end
  end
end
