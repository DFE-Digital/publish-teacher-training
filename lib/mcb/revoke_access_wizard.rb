module MCB
  class RevokeAccessWizard
    def initialize(cli, user, provider)
      @cli = cli
      @user = user
      @provider = provider
    end

    def run
      fetch_organisation
      puts MCB::Render::ActiveRecord.user @user
      confirm_and_remove_user_from_organisation
    end

  private

    def fetch_organisation
      @organisation = @provider.organisations.first # a provider should only ever be associated with one organisation
    end

    def confirm_and_remove_user_from_organisation
      if @user.in?(@organisation.users)
        puts "\n"
        puts "You're revoking access for #{@user.email} to organisation #{@organisation.name}."
        puts MCB::Render::ActiveRecord.providers_table @organisation.providers, name: "Provider access being revoked"
        @organisation.users.delete(@user) if @cli.agree("Agree?  ")
      else
        puts "#{@user.email} already has no access to #{@organisation.name}"
      end
    end
  end
end
