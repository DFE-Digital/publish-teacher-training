# frozen_string_literal: true

module FeatureHelpers
  module PageObjectMethodCreator
    Dir['spec/support/page_objects/{publish,shared}/**/*.rb'].each do |file|
      file_segments = file.chomp('.rb').split('/')
      page_objects_dir, application_type, *path_to_file, filename = file_segments[2..file_segments.length]

      method_name = if application_type == 'support'
                      ([application_type, *path_to_file, filename] + ['page']) .join('_')
                    else
                      ([filename] + ['page']) .join('_')
                    end
      page_object_path = [page_objects_dir, application_type, *path_to_file, filename].join('/').camelize

      define_method method_name do
        return instance_variable_get("@#{method_name}") if instance_variable_get("@#{method_name}").present?

        page_object = page_object_path.constantize.new

        instance_variable_set("@#{method_name}", page_object)
      end
    end
  end
end
