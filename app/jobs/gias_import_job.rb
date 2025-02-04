# frozen_string_literal: true

class GiasImportJob < ApplicationJob
  queue_as :default

  def perform
    downloaded_csv = Gias::Downloader.call

    transformed_csv = Gias::Transformer.call(downloaded_csv)

    Gias::Importer.call(transformed_csv)
  end
end
