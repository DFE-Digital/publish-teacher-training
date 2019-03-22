summary 'Import UCAS preferences for providers'
param :filename

run do |_opts, args, _cmd|
  MCB.init_rails

  import_file = args.first

  CSV.foreach(import_file, headers: true) do |row|
    provider = Provider.find_by(provider_code: row['INST_CODE'])
    attribute = case row['PREF_TYPE']
                when 'Type of GT12 required' then 'type_of_gt12'
                when 'New UTT application alerts' then 'send_application_alerts'
                end
    puts "%4<code>s %23<attribute>s: %36<old_value>s -> %-36<new_value>s" % {
      code: provider.provider_code,
      attribute: attribute,
      old_value: provider.ucas_preferences.attributes_before_type_cast[attribute],
      new_value: row['PREF_VALUE']
    }
  end
end
