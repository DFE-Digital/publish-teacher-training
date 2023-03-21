if Rails.env.development?
  module InstanceVariableErrorCheck
    def instance_variable_get(name)
      result = super(name)
      raise NameError, "Instance variable '#{name}' is not defined" if result.nil? && !instance_variable_defined?(name)

      result
    end
  end

  ActionView::Base.prepend(InstanceVariableErrorCheck)
end
