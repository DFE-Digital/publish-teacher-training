# frozen_string_literal: true

class ProviderReportingService
  def initialize(providers_scope: Provider)
    @providers = providers_scope.distinct

    @training_providers = @providers.where(id: Course.findable.select(:provider_id))
    @open_providers = @providers.where(id: Course.findable.application_status_open.select(:provider_id))

    @closed_providers = @training_providers.where.not(id: @open_providers)
  end

  class << self
    def call(providers_scope:)
      new(providers_scope:).call
    end
  end

  def call
    {
      total: {
        all: @providers.count,
        non_training_providers: @providers.count - @training_providers.count,
        training_providers: @training_providers.count,
      },
      training_providers: {
        findable_total: {
          open: @open_providers.count,
          closed: @closed_providers.count,
        },
        accredited_provider: { **group_by_count(:accredited) },
        provider_type: { **group_by_count(:provider_type) },
        region_code: { **group_by_count(:region_code) },
      },
    }
  end

  private_class_method :new

private

  def group_by_count(column)
    open = @open_providers.group(column).count
    closed = @closed_providers.group(column).count
    column_name = column.to_s.pluralize

    {
      open: Provider.send(column_name).map { |key, _value|
              x = {}
              x[key.to_sym] = open[key] || 0
              x
            }.reduce({}, :merge),
      closed: Provider.send(column_name).map { |key, _value|
                x = {}
                x[key.to_sym] = closed[key] || 0
                x
              }.reduce({}, :merge),
    }
  end
end
