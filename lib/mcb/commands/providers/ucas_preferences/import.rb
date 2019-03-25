require 'logger'

summary 'Import UCAS preferences for providers'
param :filename
# options :v, 'verbose', 'display what is being done while running'
option :n, 'dry_run', "don't update anything, display what would be done"

LOGGER = Logger.new($stdout)

LOGGER.formatter = proc do |severity, _datetime, _progname, msg|
  if severity == Logger::INFO
    msg + "\n"
  else
    "#{severity}: #{msg}\n"
  end
end

def translate_ucas_preference_to_attribute(ucas_preference)
  case ucas_preference
  when 'Type of GT12 required' then 'type_of_gt12'
  when 'New UTT application alerts' then 'send_application_alerts'
  end
end

run do |opts, args, _cmd| # rubocop: disable Metrics/BlockLength
  MCB.init_rails

  import_filename = args.first
  import_file = File.open(import_filename)
  csv = CSV.new(import_file, headers: true)
  csv.each do |row|
    provider = Provider.find_by!(provider_code: row['INST_CODE'])
    attribute = translate_ucas_preference_to_attribute(row['PREF_TYPE'])

    if attribute.present?
      puts "%4<code>s %23<attribute>s: %36<old_value>s -> %-36<new_value>s" % {
        code: provider.provider_code,
        attribute: attribute,
        old_value: provider.ucas_preferences&.attributes_before_type_cast&.fetch(attribute),
        new_value: row['PREF_VALUE']
      }
    end
  rescue ActiveRecord::RecordNotFound => exx
    if opts[:dry_run]
      LOGGER.warn(
        '[%<lineno>d] Message "%<message>s" while processing %<code>s' % {
          lineno: csv.lineno,
          message: exx.message,
          code: row['INST_CODE']
        }
      )
    else
      raise
    end
  end
end
