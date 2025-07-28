module DataHub
  class UpdateSitesFromGiasProcessSummary < ProcessSummary
    jsonb_accessor :short_summary,
                   updated_total_count: :integer,
                   updated_location_name: :integer,
                   updated_latlon: :integer,
                   updated_address3: :integer,
                   error: :string,
                   dry_run: :boolean

    jsonb_accessor :full_summary,
                   site_updates: [:jsonb, { array: true, default: [] }]
  end
end
