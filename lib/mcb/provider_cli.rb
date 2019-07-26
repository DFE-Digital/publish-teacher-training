module MCB
  class ProviderCLI < BaseCLI
    def ask_name
      @cli.ask("Enter new name?  ").strip
    end

    def ask_provider_type
      ask_multiple_choice(
        prompt: "What kind of provider is it?",
        choices: Provider.provider_types.keys
      )
    end

    def ask_new_provider_code
      @cli.ask("What's the new provider code?  ")
    end

    def ask_address
      {
        address1: @cli.ask('Building and street: '),
        address2: @cli.ask('Building and street (2nd line): '),
        town_or_city: @cli.ask('Town and city: '),
        county: @cli.ask('County: '),
        postcode: @cli.ask('Postcode: '),
      }
    end

    def ask_contact
      {
        name: @cli.ask('Contact name: '),
        email: @cli.ask('Internal contact email (for sharing with UCAS): '),
        telephone: @cli.ask('Internal contact phone number (for sharing with UCAS): '),
      }
    end

    def ask_region_code
      ask_multiple_choice(
        prompt: "Region code?",
        choices: Provider.region_codes.keys
      )
    end

    def ask_url
      @cli.ask('Provider URL? ')
    end

    def ask_organisation_name
      @cli.ask("What organisation should the new provider be added to?  ")
    end

    def ask_name_of_first_location
      @cli.ask("What's the name of the first location?  ")
    end

    def confirm_new_organisation_needed?
      @cli.agree("This organisation doesn't exist. Do you want to create a new one?  ")
    end
  end
end
