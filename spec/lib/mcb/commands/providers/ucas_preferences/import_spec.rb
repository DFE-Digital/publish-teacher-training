require "rails_helper"
require 'mcb'
require 'stringio'
require 'csv'

describe 'mcb providers ucas_preferences import' do
  def write_csv_to_tmpfile(*lines)
    tmpfile = Tempfile.new('providers_preferences')
    csv = CSV.generate(headers: csv_headers, write_headers: true) do |csv_file|
      lines.each { |l| csv_file << l }
    end
    tmpfile.write(csv)
    tmpfile.close
    tmpfile
  end

  def import_csv_file(tmpfile, opts = [])
    with_stubbed_stdout(stdin: "yes\n") do
      cmd.run(opts + [tmpfile.path])
    end
  end

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
  let(:original_preferences) do
    build :provider_ucas_preference,
          type_of_gt12: 'coming_or_not',
          send_application_alerts: 'all'
  end
  let(:provider) { create(:provider, ucas_preferences: original_preferences) }
  let(:importable_type_of_gt12_not_coming) do
    build :importable_ucas_preference,
          :type_of_gt12_not_coming,
          provider: provider
  end
  let(:importable_send_application_alerts_not_required) do
    build :importable_ucas_preference,
          provider: provider,
          PREF_TYPE: 'New UTT application alerts',
          PREF_VALUE: 'No, not required'
  end
  let(:importable_unknown_preference) do
    build :importable_ucas_preference,
          provider: provider,
          PREF_TYPE: 'Copy Form Sequence',
          PREF_VALUE: 'Alphabetic coming'
  end
  let(:output) { import_csv_file(tmpfile) }

  after :each do
    # NB: If ... IF ... something goes wrong in the spec before tmpfile gets
    #     created, then yes ... we end up creating it here. But when would
    #     that EVER happen? amiright?
    tmpfile.unlink
  end

  context 'importing empty CSV file' do
    let(:tmpfile) { write_csv_to_tmpfile }

    it 'displays no changes' do
      expect(output).to match <<~EOMESSAGE
        0 provider(s) changed. No changes, finishing early.
        Aborting without updating.
      EOMESSAGE
    end

    it "doesn't change the provider" do
      provider

      expect {
        import_csv_file(tmpfile)
      }.not_to(change { provider.reload })
    end
  end

  context 'importing preferences for providers' do
    let(:tmpfile) do
      write_csv_to_tmpfile(
        importable_type_of_gt12_not_coming,
        importable_send_application_alerts_not_required,
        importable_unknown_preference
      )
    end
    let(:nonexistent_provider) { build(:provider) }
    let(:preferences_for_unknown_provider) do
      build :importable_ucas_preference,
            provider: nonexistent_provider,
            PREF_TYPE: 'Type of GT12 required',
            PREF_VALUE: 'Not coming'
    end

    it "displays preferences that will be changed" do
      output = with_stubbed_stdout(stdin: "yes\n") do
        cmd.run([tmpfile.path])
      end

      # rubocop: disable Layout/TrailingWhitespace
      expect(output.squeeze(' ')).to match <<~EOEXPECTED.chomp
        \ #{provider.provider_code} type_of_gt12: Coming or Not -> Not coming\ 
        \ #{provider.provider_code} send_application_alerts: Yes, required -> No, not required\ 
        1 provider(s) changed. Continue?\ 
      EOEXPECTED
      # rubocop: enable Layout/TrailingWhitespace
    end

    it 'changes the given preferences when confirmation is given' do
      with_stubbed_stdout(stdin: "yes\n") do
        cmd.run([tmpfile.path])
      end

      provider.reload
      expect(provider.ucas_preferences.type_of_gt12).to eq 'not_coming'
      expect(provider.ucas_preferences.send_application_alerts).to eq 'none'
    end

    it 'does not change anything if confirmation is not given' do
      expect {
        with_stubbed_stdout(stdin: "no\n") do
          cmd.run([tmpfile.path])
        end
      }.not_to(change do
                 provider.ucas_preferences.reload.slice :type_of_gt12,
                                                        :send_application_alerts
               end)
    end

    it "instantiates provider UCAS preferences when they don't exist" do
      provider.ucas_preferences.delete

      with_stubbed_stdout(stdin: "yes\n") do
        cmd.run([tmpfile.path])
      end

      provider.reload
      expect(provider.ucas_preferences.type_of_gt12).to eq 'not_coming'
      expect(provider.ucas_preferences.send_application_alerts).to eq 'none'
    end

    it 'raises an error when a provider cannot be found' do
      tmpfile = write_csv_to_tmpfile(
        preferences_for_unknown_provider
      )
      expect { import_csv_file(tmpfile) }.to(
        raise_error(
          ActiveRecord::RecordNotFound,
          "Couldn't find Provider"
        )
      )
    end

    context 'dry-run' do
      let(:opts) { ['-n'] }

      it 'does not change anything even if confirmation is given' do
        expect { import_csv_file(tmpfile, opts) }.not_to(
          change do
            provider.ucas_preferences.reload.slice :type_of_gt12,
                                                   :send_application_alerts
          end
        )
      end

      it 'displays a warning when a provider cannot be found' do
        tmpfile = write_csv_to_tmpfile(
          preferences_for_unknown_provider
        )

        output = import_csv_file(tmpfile, opts)

        expected_code = nonexistent_provider.provider_code
        expect(output).to match <<~EOMESSAGE
          WARN: [2] Message "Couldn't find Provider" while processing #{expected_code}
          0 provider(s) changed. Dry-run, finishing early.
          Aborting without updating.
        EOMESSAGE
      end
    end
  end
end
