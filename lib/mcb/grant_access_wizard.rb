module MCB
  class GrantAccessWizard
    def initialize(cli, provider)
      @cli = cli
      @provider = provider
    end

    def run
      fetch_organisation
      ask_email
      find_or_init_user
      should_continue = persist_user_if_new
      confirm_and_add_user_to_organisation if should_continue
    end

  private

    def fetch_organisation
      @organisation = @provider.organisations.first # a provider should only ever be associated with one organisation
    end

    def ask_email
      @email = @cli.ask("Email address of user?  ").strip.downcase
    end

    def find_or_init_user
      @user = User.find_or_initialize_by(email: @email) do |u|
        puts "#{@email} appears to be a new user"
        u.first_name = @cli.ask("First name?  ").strip
        u.last_name = @cli.ask("Last name?  ").strip
      end
    end

    def persist_user_if_new
      if @user.new_record?
        if !@user.valid?
          puts "Cannot create this user:"
          @user.errors.full_messages.each do |message|
            puts "- #{message}"
          end
          return false
        elsif @cli.agree("About to create #{@user}. Continue? ")
          @user.save!
          true
        else
          return false
        end
      end
      true
    end

    def confirm_and_add_user_to_organisation
      if @user.in?(@organisation.users)
        puts "#{@user} already belongs to #{@organisation.name}"
      else
        puts "You're about to give #{@user} access to #{@organisation.name}. They will manage:"
        @organisation.providers.each do |p|
          puts " - #{p.provider_name} (#{p.provider_code})"
        end
        @organisation.users << @user if @cli.agree("Agree?  ")
      end
    end
  end
end
