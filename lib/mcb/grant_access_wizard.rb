module MCB
  class GrantAccessWizard
    def initialize(cli, id_or_email_or_sign_in_id, provider, admin)
      @cli = cli
      @id_or_email_or_sign_in_id = id_or_email_or_sign_in_id
      @provider = provider
      @admin = admin
    end

    def run
      return unless setup_user

      if @admin
        confirm_and_add_user_to_all_organisations
      else
        confirm_and_add_user_to_organisation
      end
    end

  private

    def setup_user
      return false unless find_or_init_user

      puts MCB::Render::ActiveRecord.user @user

      persist_user_if_new
    end

    def find_or_init_user
      @user = MCB.find_user_by_identifier @id_or_email_or_sign_in_id
      return @user if @user != nil

      unless @id_or_email_or_sign_in_id.include? '@'
        puts "#{@id_or_email_or_sign_in_id} not found. Specify an email address if you wish to create a user"
        return nil
      end

      @user = User.new(email: @id_or_email_or_sign_in_id)
      puts "#{@id_or_email_or_sign_in_id} appears to be a new user"
      @user.first_name = @cli.ask("First name?  ").strip
      @user.last_name = @cli.ask("Last name?  ").strip
      @user
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
      unless @provider
        puts "\n"
        puts "Error: specify a provider code"
        return
      end

      @organisation = @provider.organisations.first # a provider should only ever be associated with one organisation
      if @user.in?(@organisation.users)
        puts "#{@user} already belongs to #{@organisation.name}"
        return
      end

      add_user_to_org
    end

    def add_user_to_org
      puts "\n"
      puts "You're about to give #{@user} access to organisation #{@organisation.name}. They will manage:"
      puts MCB::Render::ActiveRecord.providers_table @organisation.providers, name: "Additional Providers"
      @organisation.users << @user if @cli.agree("Agree?  ")
    end

    def confirm_and_add_user_to_all_organisations
      unless @user.admin?
        puts "Refusing to give non-admin user #{@user} access to all orgs"
        return nil
      end

      add_user_to_all_organisations
    end

    def add_user_to_all_organisations
      @user.organisations = Organisation.all

      puts "\n"
      puts "#{@user} given access to all orgs"
    end
  end
end
