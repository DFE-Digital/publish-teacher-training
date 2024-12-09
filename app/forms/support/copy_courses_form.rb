# frozen_string_literal: true

module Support
  class CopyCoursesForm
    include ActiveModel::Model

    attr_reader :target_provider, :provider

    def initialize(target_provider, provider = nil)
      @target_provider = target_provider
      @provider = provider
    end

    validates :target_provider, :provider, presence: true
  end
end
