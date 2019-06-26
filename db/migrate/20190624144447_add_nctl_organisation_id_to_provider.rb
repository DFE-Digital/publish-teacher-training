class AddNCTLOrganisationIdToProvider < ActiveRecord::Migration[5.2]
  def up
    add_reference :provider, :nctl_organisation

    say_with_time('updating providers') do
      Provider.reset_column_information

      Provider.all.includes(:organisations).each do |provider|
        nctl_organisation =
          if fixed_mappings.key? provider.provider_code
            NCTLOrganisation.find_by(
              nctl_id: fixed_mappings[provider.provider_code]
            )
          else
            nctl_organisation_for(provider) rescue nil
          end

        if nctl_organisation
          provider.update! nctl_organisation: nctl_organisation
        end
      end
    end
  end

  def down
    remove_reference :provider, :nctl_organisation
  end

  def nctl_organisation_for(provider)
    potential_organisations = if provider.accredited_body?
                                provider.organisation&.nctl_organisations.accredited_body
                              else
                                provider.organisation&.nctl_organisations.school
                              end

    if potential_organisations.size <= 1
      potential_organisations.first
    else
      raise "Multiple potential NCTL orgs found: #{potential_organisations.pluck(:nctl_id).join(', ')} for provider #{provider.provider_code}"
    end
  end

  def fixed_mappings
    @fixed_mappings ||= Hash[CSV.parse(<<~EOCSV).map(&:reverse)]
      11248,1LN
      11449,153
      13610,1FG
      10532,2CJ
      10532,2CG
      10532,2CK
      10532,2CL
      10532,2CH
      10532,15W
      10532,2CF
      10817,2D1
      10962,2GQ
      11017,1ED
      11829,1Z4
      11067,1V9
      10477,1AJ
      10979,1AY
      11200,1UR
      11080,28A
      11080,1T7
      10073,1B7
      11651,1K9
      11368,13O
      10929,2GJ
      10069,1RC
      10724,2BQ
      11216,2K4
      10142,219
      12055,2K7
      10466,186
      5650,25E
      5568,L26
      1532,L24
      12037,1F9
      10009,1ZY
      12037,1VA
      10009,1VA
      10950,2G9
      11267,1GV
      10373,2JN
      11261,1T2
      10320,1CV
      11305,2H3
      11305,1EL
      11305,2BV
      13615,1V7
      11077,2LC
      11207,27F
      11207,2KC
      10849,2DO
      10849,16E
      11156,1NP
      11156,2KQ
      11296,2J5
      11296,264
      11162,2KP
      11162,27C
      5616,K51
      5616,1S2
      11170,1R1
      11220,2K2
      5520,1LP
      12055,1E6
      13624,2LM
      11859,18L
      5552,S13
      5615,1WP
      5541,S14
    EOCSV
  end
end
