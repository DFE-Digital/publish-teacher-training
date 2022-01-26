module PublishInterface
  class CourseCreationForm < BaseModelForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks

    alias_method :course, :model

    attr_accessor :store

    def initialize(*args)
      super
      @store = FormStore
    end

    def stash
      valid? && store.set(form_store_key, fields)
    end
  end
end
