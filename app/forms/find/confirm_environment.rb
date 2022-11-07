module Find
  class ConfirmEnvironment
    include ActiveModel::Model
    attr_accessor :from, :environment

    validate :correct_environment

    def correct_environment
      if environment != Rails.env
        errors.add(:environment, :invalid_environment, environment: Rails.env)
      end
    end
  end
end
