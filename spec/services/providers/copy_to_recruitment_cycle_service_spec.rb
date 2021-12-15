require "rails_helper"

describe Providers::CopyToRecruitmentCycleService do
  describe "#execute" do
    let(:site) { build :site }
    let(:published_course_enrichment) { build :course_enrichment, :published }
    let(:course) { create :course, enrichments: [published_course_enrichment], provider: provider }
    let(:ucas_preferences) { build(:ucas_preferences, type_of_gt12: :coming_or_not) }
    let(:contacts) {
      [
        build(:contact, :admin_type),
        build(:contact, :utt_type),
        build(:contact, :web_link_type),
        build(:contact, :finance_type),
        build(:contact, :fraud_type),
      ]
    }
    let(:provider) {
      create :provider,
             sites: [site],
             ucas_preferences: ucas_preferences,
             contacts: contacts
    }
    let(:recruitment_cycle) { find_or_create :recruitment_cycle }
    let(:new_recruitment_cycle) { create :recruitment_cycle, :next }
    let(:new_provider) do
      new_recruitment_cycle.reload.providers.find_by(
        provider_code: provider.provider_code,
      )
    end
    let(:mocked_copy_course_service) { double(execute: nil) }
    let(:mocked_copy_site_service) { double(execute: nil) }
    let(:service) do
      described_class.new(
        copy_course_to_provider_service: mocked_copy_course_service,
        copy_site_to_provider_service: mocked_copy_site_service,
      )
    end

    before do
      course
    end

    it "makes a copy of the provider in the new recruitment cycle" do
      expect(
        new_recruitment_cycle.providers.find_by(
          provider_code: provider.provider_code,
        ),
      ).to be_nil

      service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)

      expect(new_provider).not_to be_nil
      expect(new_provider).not_to eq provider
    end

    it "leaves the existing provider alone" do
      service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)

      expect(recruitment_cycle.reload.providers).to eq [provider]
    end

    context "an error occurs when copying the course" do
      it "logs a useful message to the provided logger" do
        log_output = StringIO.new
        logger = Logger.new(log_output)
        service = described_class.new(
          copy_course_to_provider_service: mocked_copy_course_service,
          copy_site_to_provider_service: mocked_copy_site_service,
          logger: logger,
        )
        allow(mocked_copy_course_service).to receive(:execute).and_raise("Nope")

        expect {
          service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)
        }.to raise_error("Nope")

        expect(log_output.string).to include "error trying to copy course #{course.course_code}"
      end
    end

    context "the provider already exists in the new recruitment cycle" do
      let(:old_recruitment_cycle) { create :recruitment_cycle, :previous }
      let(:new_provider) {
        create :provider, recruitment_cycle: old_recruitment_cycle, provider_code: provider.provider_code
      }
      let(:new_recruitment_cycle) {
        create :recruitment_cycle, :next,
               providers: [new_provider]
      }

      it "does not make a copy of the provider" do
        expect { service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle) }
          .not_to(change { new_recruitment_cycle.reload.providers.count })
      end

      it "copies over the sites" do
        service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)

        expect(mocked_copy_site_service).to have_received(:execute).with(site: site, new_provider: new_provider)
      end

      it "copies over the courses" do
        service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)

        expect(mocked_copy_course_service).to have_received(:execute).with(course: course, new_provider: new_provider)
      end
    end

    it "copies over the ucas_preferences" do
      service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)

      compare_attrs = %w[
        type_of_gt12
        send_application_alerts
        application_alert_email
        gt12_response_destination
      ]
      expect(new_provider.ucas_preferences.attributes.slice(compare_attrs))
        .to eq provider.ucas_preferences.attributes.slice(compare_attrs)
    end

    it "copies over the contacts" do
      service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)

      compare_attrs = %w[name email telephone]
      expect(new_provider.contacts.map { |c| c.attributes.slice(compare_attrs) })
        .to eq(provider.contacts.map { |c| c.attributes.slice(compare_attrs) })
    end

    it "copies over the sites" do
      service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)

      expect(mocked_copy_site_service).to have_received(:execute).with(site: site, new_provider: new_provider)
    end

    it "copies over the courses" do
      service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)

      expect(mocked_copy_course_service).to have_received(:execute).with(course: course, new_provider: new_provider)
    end

    it "returns a hash of the counts of copied objects" do
      allow(mocked_copy_course_service).to receive(:execute).and_return(double)
      allow(mocked_copy_site_service).to receive(:execute).and_return(double)

      output = service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)

      expect(output).to eq(
        providers: 1,
        sites: 1,
        courses: 1,
      )
    end

    context "provider is not rollable?" do
      context "force: true" do
        before do
          allow(provider).to receive(:rollable?).and_return(false)
        end

        it "still copies the provider" do
          expect {
            service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle, force: true)
          }.to(change { new_recruitment_cycle.providers.count })
        end
      end
    end
  end
end
