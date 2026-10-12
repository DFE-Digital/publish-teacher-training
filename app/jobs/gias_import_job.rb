# frozen_string_literal: true

class GiasImportJob < ApplicationJob
  queue_as :low_priority

  # The import upserts by URN, so a later attempt is always safe. The specific
  # retries below must stay after `retry_on_failure` so their waits win (LIFO).
  retry_on_failure

  # Yesterday's GIAS file is sometimes late or the download drops.
  retry_on Gias::DownloadError, attempts: 3, wait: 30.minutes
  retry_on(
    ActiveRecord::ConnectionFailed,
    ActiveRecord::ConnectionNotEstablished,
    PG::ConnectionBad,
    attempts: 3,
    wait: 5.minutes,
  )

  def perform
    downloaded_csv = Gias::Downloader.call

    transformed_csv = Gias::Transformer.call(downloaded_csv)

    Gias::Importer.call(transformed_csv)
  end
end
