# frozen_string_literal: true

module FeatureHelpers
  module PageObject
    module Helper
      def self.get_pages_to_make(page_object_type)
        Dir["spec/support/page_objects/#{page_object_type}/**/*.rb"].map do |file|
          file_segments = file.chomp('.rb').split('/')
          page_objects_dir, application_type, *path_to_file, filename = file_segments[2..file_segments.length]

          method_name = if application_type == 'support'
                          ([application_type, *path_to_file, filename] + ['page']) .join('_')
                        else
                          ([filename] + ['page']) .join('_')
                        end
          page_object_path = [page_objects_dir, application_type, *path_to_file, filename].join('/').camelize

          [method_name, page_object_path]
        end
      end
    end
  end
end
