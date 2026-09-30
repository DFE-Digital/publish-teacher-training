# frozen_string_literal: true

class GiasImportJob < ApplicationJob
  self.queue_adapter = :solid_queue
  queue_as :default

  # Yesterday's GIAS file is sometimes late or the download drops. The import
  # upserts by URN, so a later attempt is safe; anything else fails once.
  retry_on Gias::DownloadError, attempts: 3, wait: 30.minutes

  def perform
    downloaded_csv = Gias::Downloader.call

    transformed_csv = Gias::Transformer.call(downloaded_csv)

    Gias::Importer.call(transformed_csv)
  end
end
