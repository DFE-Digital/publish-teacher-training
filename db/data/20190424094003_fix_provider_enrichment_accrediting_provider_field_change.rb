class FixProviderEnrichmentAccreditingProviderFieldChange < ActiveRecord::Migration[5.2]
  def self.up
    execute "UPDATE   provider_enrichment
                SET   json_data = Replace(json_data :: text, '\"UcasInstitutionCode\":',
                              '\"UcasProviderCode\":') ::
                              jsonb
              WHERE   json_data :: text LIKE '%\"UcasInstitutionCode\":%';"
  end

  def self.down
    execute "UPDATE   provider_enrichment
                SET   json_data = Replace(json_data :: text, '\"UcasProviderCode\":',
                              '\"UcasInstitutionCode\":') ::
                              jsonb
              WHERE   json_data :: text LIKE '%\"UcasProviderCode\":%';"
  end
end
