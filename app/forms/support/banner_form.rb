# frozen_string_literal: true

module Support
  class BannerForm < ApplicationForm
    attribute :name, :string
    attribute :heading, :string
    attribute :body, :string
    attribute :display_on_find, :boolean
    attribute :display_on_publish, :boolean
    attribute :display_on_support, :boolean
    attribute :published_at, :multiple_parameters_date_time, blank_time: :beginning_of_day
    attribute :expired_at, :multiple_parameters_date_time, blank_time: :end_of_day

    validates :published_at, :expired_at, multiple_parameters_date_time: true

    def self.date_time_attribute_types
      attribute_types.select { |_, type| type.is_a?(MultipleParametersDateTimeType) }
    end

    def initialize(params = {})
      super(MultipleParametersDateTimeType.process(params.to_h, self.class.date_time_attribute_types))
    end

    def banner_attributes
      attributes.symbolize_keys
    end
  end
end
