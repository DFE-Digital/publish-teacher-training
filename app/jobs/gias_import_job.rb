# frozen_string_literal: true

class GiasImportJob < ApplicationJob
  self.queue_adapter = :solid_queue
  queue_as :default

  # The importer upserts by URN, so a failed download is safe to try again.
  retry_on Gias::DownloadError, attempts: 3, wait: 5.minutes

  def perform
    downloaded_csv = Gias::Downloader.call

    transformed_csv = Gias::Transformer.call(downloaded_csv)

    Gias::Importer.call(transformed_csv)
  end
end
