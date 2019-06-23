task :mappings_from_nctl_to_ucas => :environment do
  require 'csv'

  data = CSV.generate do |csv|
    comparison = NCTLOrganisation.all.collect do |nctl_org|
      begin
        provider = nctl_org.provider
        csv << [nctl_org.nctl_id, nctl_org.name, provider&.provider_code, provider&.provider_name]
      rescue RuntimeError => e
        csv << [nctl_org.nctl_id, nctl_org.name, e.message, '']
      end
    end
  end
  puts data
end

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
