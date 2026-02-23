# frozen_string_literal: true

helper_module_names = %w[
  GovukComponentsHelper
  GovukLinkHelper
  GovukListHelper
  GovukVisuallyHiddenHelper
].freeze

module ViewComponentGovukHelpersProxy
  def self.install!(base_class, helper_modules)
    method_names = helper_modules.flat_map { |mod| mod.instance_methods(false) }
                                 .grep(/\Agovuk_/)
                                 .uniq

    method_names.each do |method_name|
      next if base_class.instance_methods.include?(method_name)

      base_class.define_method(method_name) do |*args, **kwargs, &block|
        if kwargs.empty?
          helpers.public_send(method_name, *args, &block)
        else
          helpers.public_send(method_name, *args, **kwargs, &block)
        end
      end
    end
  end
end

Rails.application.config.to_prepare do
  helper_modules = helper_module_names.filter_map(&:safe_constantize)
  [ViewComponent::Base, (GovukComponent::Base if defined?(GovukComponent::Base))].compact.each do |base_class|
    ViewComponentGovukHelpersProxy.install!(base_class, helper_modules)
  end
end
