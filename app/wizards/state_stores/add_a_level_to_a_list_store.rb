# frozen_string_literal: true

module StateStores
  class AddALevelToAListStore
    include DfE::Wizard::StateStore

    def save
      if existing_a_level_subject?
        update_existing_a_level_subject_requirement
      else
        add_a_level_subject_requirement
      end

      course.save
    end
  end
end
