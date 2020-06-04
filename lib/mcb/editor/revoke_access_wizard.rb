module MCB
  module Editor
    class RevokeAccessWizard < MCB::Editor::Base
      def initialize(provider, user)
        @user = user
        @requester = User.find_by!(email: MCB.config[:email])

        super(provider: provider, requester: @requester)
      end

      def run
        fetch_organisations
        puts MCB::Render::ActiveRecord.user @user
        confirm_and_remove_user_from_organisation
      end

    protected

      def setup_cli
        @cli = HighLine.new
      end

      def check_authorisation
        UserPolicy.new(@requester, @user).remove_access_to?
      end

    private

      def fetch_organisations
        @organisations = if @provider
          # we use first because a provider should only ever be associated with one organisation
                           [@provider.organisations.first]
                         else
                           @user.organisations
                         end
      end

      def confirm_and_remove_user_from_organisation
        if (@user.organisations & @organisations).any?
          puts "\n"
          puts "You're revoking access for #{@user.email} to:"
          puts MCB::Render::ActiveRecord.organisations_table @organisations, name: "Organisation access being revoked"
          puts MCB::Render::ActiveRecord.providers_table @organisations.map(&:providers).flatten, name: "Provider access being revoked"
          unless @cli.agree("Agree?  ")
            return
          end

          UserAssociationsService::Delete.call(user: @user, organisations: @organisations)
        else
          puts "#{@user.email} already has no access to #{@provider}"
        end
      end
    end
  end
end
