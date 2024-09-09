# frozen_string_literal: true

module DataMigrations
  class SetSelectableSchoolsOnProviders
    def change
      provider_codes = %w[E65 2CG 2CH 2CJ 2CK 2C1 1EX 1QU CS01 2X4 1ZO]
      Provider.where(provider_code: provider_codes).update_all(selectable_school: true)
    end
  end
end

desc 'Set Selectable Schools on 11 providers'
task set_selectable_schools: :environment do |_, _args|
  DataMigrations::SetSelectableSchoolsOnProviders.new.change
end
