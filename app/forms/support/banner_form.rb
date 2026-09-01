# frozen_string_literal: true

module Support
  class BannerForm < ApplicationForm
    attribute :name, :string
    attribute :heading, :string
    attribute :body, :string
    attribute :display_on_find, :boolean
    attribute :display_on_publish, :boolean
    attribute :display_on_support, :boolean
    attribute :published_at, :multiple_parameters_date_time
    attribute :expired_at, :multiple_parameters_date_time

    validates :published_at, :expired_at, multiple_parameters_date_time: true

    def initialize(params = {})
      super(MultipleParametersDateTimeType.process(params.to_h))
    end

    def banner_attributes
      attributes.symbolize_keys
    end
  end
end
