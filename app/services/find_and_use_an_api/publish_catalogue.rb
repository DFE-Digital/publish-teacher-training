# frozen_string_literal: true

module FindAndUseAnAPI
  class PublishCatalogue
    include ServicePattern

    class Error < StandardError; end

    def call
      manifest = BuildManifest.call

      client.import(manifest)
      client.publish(entry_id(manifest.fetch("name"), manifest.fetch("majorVersion")))
    end

  private

    def entry_id(name, major_version)
      matches = client.list_apis.select { |api| api["name"] == name && api["majorVersion"] == major_version }

      case matches.size
      when 1 then matches.first.fetch("id")
      when 0 then raise Error, "No catalogue entry for #{name} #{major_version} after import"
      else raise Error, "Several catalogue entries for #{name} #{major_version}: ids #{matches.pluck('id').join(', ')}"
      end
    end

    def client
      @client ||= Client.new
    end
  end
end
