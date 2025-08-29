module Providers
  class PromoteTrainingProviderAccreditation
    def initialize(training_provider, number)
      @training_provider = training_provider
      @number = number
    end

    def call
      Provider.transaction do
        # Destroy partnerships
        partners = training_provider.accredited_partners.pluck(:provider_name)
        training_provider.accredited_partnerships.destroy_all
        log "Partnerships destroyed:"
        partners.each do |partner|
          log partner.indent(2)
        end

        # Update provider_type
        if training_provider.lead_school?
          training_provider.update(provider_type: :scitt)
        end

        # Reset accredited provider on Courses
        training_provider.courses.each do
          it.accredited_provider_code = nil
          it.save!(validate: false)
        end

        # Update Provider attributes
        training_provider.update(accredited_provider_number: number, accredited: true)

        # Save with a bang
        training_provider.save!

        # Log the result
        log "#{@training_provider.name_and_code} has been upgraded to an accredited provider!"
      end
    end

  private

    def log(text)
      Rails.logger.tagged("PromoteTrainingProviderAccreditation") { it.info(text) }
    end
    attr_reader :training_provider, :number
  end
end
