class ProviderReportingService
  def initialize(providers_scope: Provider)
    @providers = providers_scope.distinct

    @training_provider = @providers.where(id: Course.findable.select(:provider_id))
    @open_providers = @providers.where(id: Course.findable.with_vacancies.select(:provider_id))

    @closed_providers = @training_provider.where.not(id: @open_providers)
  end

  class << self
    def call(providers_scope:)
      new(providers_scope: providers_scope).call
    end
  end

  def call
    {
      total: {
        all: @providers.count,
        non_training_providers: @providers.count - @training_provider.count,
        training_providers: @training_provider.count,
      },
      training_providers: {
        findable_total: {
          open: @open_providers.count,
          closed: @closed_providers.count,
        },
        accredited_body: { **group_by_count(:accrediting_provider) },
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

    {
      open: Provider.send(column.to_s.pluralize).map { |key, _value| x = {}; x[key.to_sym] = open[key] || 0; x }.reduce({}, :merge),
      closed: Provider.send(column.to_s.pluralize).map { |key, _value| x = {}; x[key.to_sym] = closed[key] || 0; x }.reduce({}, :merge),
    }
  end
end
