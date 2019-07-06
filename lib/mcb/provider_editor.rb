module MCB
  class ProviderEditor
    attr_reader :provider

    def initialize(provider:, requester:)
      @cli = ProviderCLI.new(provider)
      @provider = provider
      @requester = requester

      check_authorisation
    end

    def run
      finished = false
      until finished
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
      ]
      @cli.ask_multiple_choice(prompt: "What would you like to do?", choices: choices)
    end

    def perform_action(choice)
      if choice == "edit provider name"
        edit_provider_name
      end
    end

    def edit_provider_name
      puts "Current name: #{provider.provider_name}"
      update(provider_name: @cli.ask_name)
    end

    def update(attrs)
      @provider.update(attrs)
    end

    def check_authorisation
      raise Pundit::NotAuthorizedError unless ProviderPolicy.new(@requester, @provider).update?
    end
  end
end
