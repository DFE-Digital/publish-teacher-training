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
        "config/public-api-v%{version}.yml"
      end
    end
  end
end
