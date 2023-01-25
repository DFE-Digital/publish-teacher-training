module Find
  class ConfirmEnvironment
    include ActiveModel::Model
    attr_accessor :from, :environment

    validate :correct_environment

    def correct_environment
      errors.add(:environment, :invalid_environment, environment: Rails.env) if environment != Rails.env
    end
  end
end
