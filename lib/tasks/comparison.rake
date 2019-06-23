task :mappings_from_ucas_to_nctl => :environment do
  require 'csv'

  data = CSV.generate do |csv|
    comparison = Provider.where(id: Course.distinct.pluck(:accrediting_provider_id).compact).collect do |provider|
      begin
        nctl_org = provider.nctl_organisation
        csv << [provider.provider_code, provider.provider_name, nctl_org&.nctl_id, nctl_org&.name]
      rescue RuntimeError => e
        csv << [provider.provider_code, provider.provider_name, e.message, '']
      end
    end
  end
  puts data
end
