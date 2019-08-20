module MCB
  module Cli
    class ProviderCli < MCB::Cli::BaseCli
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
          town_or_city: @cli.ask('Town and city: '),
          county: @cli.ask('County: '),
          postcode: @cli.ask('Postcode: '),
        }
      end

      def ask_contact
        {
          name: @cli.ask('UCAS admin account - name: '),
          email: @cli.ask('UCAS admin account - email: '),
          telephone: @cli.ask('UCAS admin account - phone number: '),
        }
      end

      def ask_region_code
        ask_multiple_choice(
          prompt: "Region code?",
          choices: Provider.region_codes.keys
        )
      end

      def ask_organisation_name
        @cli.ask("What Organisation should the new provider be added to? (Enter Org Name)  ")
      end

      def ask_name_of_first_location
        @cli.ask("What's the name of the first location?  ")
      end

      def confirm_new_organisation_needed?
        @cli.agree("This organisation doesn't exist. Do you want to create a new one?  ")
      end
    end
  end
end
