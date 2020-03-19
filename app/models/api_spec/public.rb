module APISpec
  # Define the version and location of our public spec.
  class Public
    # This concern has all the goodness used externally.
    include APISpec

    class << self
      def latest_version_number
        1
      end

      def openapi_file_path
        "swagger/v%{version}/swagger.json"
      end
    end
  end
end
