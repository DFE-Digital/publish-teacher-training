module PublishInterface
  class BaseProviderForm < BaseModelForm
    alias_method :provider, :model
  end
end
