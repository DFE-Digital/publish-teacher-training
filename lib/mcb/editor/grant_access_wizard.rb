module MCB
  module Editor
    class GrantAccessWizard < MCB::Editor::Base
      def initialize(provider, id_or_email_or_sign_in_id)
        @id_or_email_or_sign_in_id = id_or_email_or_sign_in_id
        @requester = User.find_by!(email: MCB.config[:email])

        super(provider: provider, requester: @requester)
      end

      def run
        return unless setup_user

        confirm_and_add_user_to_organisation
      end

    protected

      def setup_cli
        @cli = HighLine.new
      end

      def check_authorisation
        OrganisationPolicy.new(@requester, @organisation).add_user?
      end

    private

      def setup_user
        return false unless find_or_init_user

        puts MCB::Render::ActiveRecord.user @user_to_grant

        persist_user_if_new
      end

      def find_or_init_user
        @user_to_grant = MCB.find_user_by_identifier @id_or_email_or_sign_in_id
        return @user_to_grant if @user_to_grant != nil

        unless @id_or_email_or_sign_in_id.include? "@"
          puts "#{@id_or_email_or_sign_in_id} not found. Specify an email address if you wish to create a user"
          return nil
        end

        @user_to_grant = User.new(email: @id_or_email_or_sign_in_id, state: "new")
        puts "#{@id_or_email_or_sign_in_id} appears to be a new user"
        @user_to_grant.first_name = @cli.ask("First name?  ").strip
        @user_to_grant.last_name = @cli.ask("Last name?  ").strip
        @user_to_grant
      end

      def persist_user_if_new
        if @user_to_grant.new_record?
          if !@user_to_grant.valid?
            puts "Cannot create this user:"
            @user_to_grant.errors.full_messages.each do |message|
              puts "- #{message}"
            end
            return false
          elsif @cli.agree("About to create #{@user_to_grant}. Continue? ")
            @user_to_grant.save!
            true
          else
            return false
          end
        end
        true
      end

      def confirm_and_add_user_to_organisation
        unless @provider
          puts "\n"
          puts "Error: specify a provider code"
          return
        end

        @organisation = @provider.organisations.first # a provider should only ever be associated with one organisation
        if @user_to_grant.in?(@organisation.users)
          puts "#{@user_to_grant} already belongs to #{@organisation.name}"
          return
        end

        add_user_to_org
      end

      def add_user_to_org
        puts "\n"
        puts "You're about to give #{@user_to_grant} access to organisation #{@organisation.name}. They will manage:"
        puts MCB::Render::ActiveRecord.providers_table @organisation.providers, name: "Additional Providers"
        UserAssociationsService::Create.call(organisation: @organisation, user: @user_to_grant) if @cli.agree("Agree?  ")
      end

      def add_user_to_all_organisations
        UserAssociationsService::Create.call(user: @user_to_grant, all_organisations: true)

        puts "\n"
        puts "#{@user_to_grant} given access to all orgs"
      end
    end
  end
end
