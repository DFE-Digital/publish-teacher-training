# frozen_string_literal: true

module Support
  class DataExportsController < ApplicationController
    def index
      @data_exports = DataExports::DataExport.all
    end

    def download
      unless (@data_export = DataExports::DataExport.find(params[:id]))
        redirect_to action: :index, error: "Unable to find data export"
        return
      end
      send_data @data_export.to_csv, filename: @data_export.filename, disposition: :attachment
    end

    def download_feedbacks
      data_export = DataExports::DataExport.find("feedback")

      unless data_export
        redirect_to action: :index, alert: "Unable to find data export" and return
      end

      send_data data_export.to_csv,
                filename: "feedbacks-#{Time.zone.now.strftime('%Y-%m-%d')}.csv",
                type: "text/csv",
                disposition: :attachment
    end
  end
end
