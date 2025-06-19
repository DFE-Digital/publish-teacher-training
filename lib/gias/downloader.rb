# frozen_string_literal: true

require "net/http"

module Gias
  class Downloader < Service
    PATH = "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public"
    def call
      yesterday = Time.zone.yesterday.strftime("%Y%m%d")
      filename = "edubasealldata#{yesterday}.csv"
      url = URI("#{PATH}/#{filename}")
      csv_path = "tmp/gias_school-#{Process.pid}.csv"

      Log.log("Gias::Downloader", "Downloading the new gias file for #{Time.zone.yesterday}", level: :info)

      begin
        # Chunking the response reduces the memory usage ~70MB
        Net::HTTP.start(url.host, url.port, use_ssl: true) do |https|
          req = Net::HTTP::Get.new(url.path)

          https.request(req) do |res|
            raise unless res.code == "200"

            Kernel.open(csv_path, "w") do |f|
              res.read_body do |chunk|
                # There are characters in the CSV that must be
                # transcoded to UTF-8 from a windows-1252
                # https://ruby-doc.org/3.3.5/String.html#method-i-encode
                f.write chunk.encode("UTF-8", "windows-1252")
              end
            end
          end
        end
      rescue StandardError
        raise DownloadError
      end

      Log.log("Gias::Downloader", "New GIAS file complete for #{Time.zone.yesterday}", level: :info)

      File.open(csv_path, "r")
    end
  end
end
