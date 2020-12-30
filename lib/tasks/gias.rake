#!/usr/bin/env ruby

require "pry"

desc "commands to operate on GIAS edubase files"
namespace :gias do
  desc "import GIAS establishments from edubase csv file"
  task import_all_establishments: :environment do
    # version = "20201229"

    filename = ENV.fetch("edubase_file")
    CSV.foreach(
      filename,
      headers: true,
      encoding: "Windows-1252",
    )
      .select { |r| r["EstablishmentStatus (name)"] == "Open" }
      .each do |record|
      GIASEstablishment.create!(
        urn: record["URN"],
        name: record["EstablishmentName"],
        postcode: record["Postcode"],
      )
    end
  end

  desc "clear GIAS establishments"
  task clear_establishments: :environment do
    GIASEstablishment.delete_all
  end
end
