# frozen_string_literal: true

class Support::AddUserWizard
  module Operations
    class CreateUser
      # repository is part of the DfE::Wizard operation interface
      # rubocop:disable Lint/UnusedMethodArgument
      def initialize(repository:, step:)
        @step = step
        @wizard = step.wizard
      end
      # rubocop:enable Lint/UnusedMethodArgument

      def execute
        user = User.new(user_attributes)

        if user.save
          { success: true }
        else
          user.errors.full_messages.each { |message| @step.errors.add(:base, message) }
          { success: false, errors: @step.errors }
        end
      end

      def rollback; end

    private

      def user_attributes
        store = @wizard.state_store

        {
          first_name: store.first_name,
          last_name: store.last_name,
          email: store.email.to_s.strip.downcase,
          admin: ActiveModel::Type::Boolean.new.cast(store.admin),
          state: "new",
        }
      end
    end
  end
end
