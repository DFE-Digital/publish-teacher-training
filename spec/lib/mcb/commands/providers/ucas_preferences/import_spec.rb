require "rails_helper"
require 'mcb'
require 'stringio'
require 'csv'

describe 'mcb providers ucas_preferences import' do
  let(:lib_dir) { "#{Rails.root}/lib" }
  let(:cmd) do
    Cri::Command.load_file(
      "#{lib_dir}/mcb/commands/providers/ucas_preferences/import.rb"
    )
  end
  let(:csv_headers) do
    %i[
        INST_CODE
        INST_ID
        VERSION
        INP_ID
        PRF_ID
        PRT_ID
        PREF_TYPE
        PREF_VALUE
        PRV_ID
      ]
  end

  def with_stubbed_stdout
    output = StringIO.new
    original_stdout = $stdout
    $stdout = output

    yield

    output
  ensure
    $stdout = original_stdout
  end

  it 'displays what will change' do
    original_preferences = build :provider_ucas_preference,
                                 type_of_gt12: 'coming_or_not',
                                 send_application_alerts: 'all'
    provider = create(:provider, ucas_preferences: original_preferences)
    new_type_of_gt12 = build :importable_ucas_preference,
                             provider: provider,
                             PREF_TYPE: 'Type of GT12 required',
                             PREF_VALUE: 'Not coming'
    new_send_application_alerts = build :importable_ucas_preference,
                                        provider: provider,
                                        PREF_TYPE: 'New UTT application alerts',
                                        PREF_VALUE: 'No, not required'


    tmpfile = Tempfile.new('providers_preferences')
    csv = CSV.generate(headers: csv_headers, write_headers: true) do |csv_file|
      csv_file << new_type_of_gt12
      csv_file << new_send_application_alerts
    end
    tmpfile.write(csv)
    tmpfile.close

    output = with_stubbed_stdout do
      cmd.run([tmpfile.path])
    end

    expect(output.string).to match %r{
      ^\s+ #{provider.provider_code}
      \s+ type_of_gt12:
      \s+ Coming\ or\ Not
      \s+ ->
      \s+ Not\ coming
    }x
    expect(output.string).to match %r{
      ^\s+ #{provider.provider_code}
      \s+ send_application_alerts:
      \s+ Yes,\ required
      \s+ ->
      \s+ No,\ not\ required
    }x
  ensure
    tmpfile&.unlink
  end
end
