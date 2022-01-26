module PublishInterface
  class CourseCreationForm < BaseModelForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks

    alias_method :course, :model

    def stash
      valid? && store.set(id, form_store_key, fields.except(*fields_to_ignore_before_stash))
    end
  end
end
