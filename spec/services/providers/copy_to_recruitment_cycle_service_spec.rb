# frozen_string_literal: true

require "rails_helper"

describe Providers::CopyToRecruitmentCycleService do
  describe "#execute" do
    let(:site) { build(:site, :school) }
    let(:study_site) { build(:site, :study_site) }
    let(:published_course_enrichment) { build(:course_enrichment, :published) }
    let(:course_enrichments) { [published_course_enrichment] }
    let(:course) { create(:course, enrichments: course_enrichments, provider: provider) }
    let(:ucas_preferences) { build(:ucas_preferences, type_of_gt12: :coming_or_not) }
    let(:contacts) do
      [
        build(:contact, :admin_type),
        build(:contact, :utt_type),
        build(:contact, :web_link_type),
        build(:contact, :finance_type),
        build(:contact, :fraud_type),
      ]
    end
    let(:provider) do
      create(:provider,
             :with_users,
             sites: [site],
             study_sites: [study_site],
             ucas_preferences: ucas_preferences,
             contacts: contacts)
    end
    let(:recruitment_cycle) { find_or_create :recruitment_cycle }
    let(:new_recruitment_cycle) { create(:recruitment_cycle, :next) }
    let(:new_provider) do
      new_recruitment_cycle.reload.providers.find_by(
        provider_code: provider.provider_code,
      )
    end
    let(:mocked_copy_course_service) { double(execute: nil) }
    let(:mocked_copy_site_service) { double }
    let(:mocked_copy_partnership_service) { double(execute: 1) }
    let(:service) do
      described_class.new(
        copy_course_to_provider_service: mocked_copy_course_service,
        copy_site_to_provider_service: mocked_copy_site_service,
        copy_partnership_to_provider_service: mocked_copy_partnership_service,
        force: force,
      )
    end
    let(:force) { false }

    # Mock successful site creation result
    let(:successful_site_result) do
      Sites::CopyToProviderService::Result.new(
        success?: true,
        site: double("Site"),
        error_message: nil,
      )
    end

    before do
      course
      # Default successful site copy behavior
      allow(mocked_copy_site_service).to receive(:execute).and_return(successful_site_result)
      allow(mocked_copy_course_service).to receive(:execute).and_return(double("Course"))
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
      it "continues with other courses and logs the error" do
        allow(mocked_copy_course_service).to receive(:execute).and_raise(StandardError.new("Nope"))

        result = service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)

        # Should not raise error, should capture it in result
        expect(result[:courses_failed]).to contain_exactly(
          { course_code: course.course_code, error_message: "Nope" },
        )
        expect(result[:courses]).to eq(0) # No courses successfully copied
      end
    end

    context "the provider already exists in the new recruitment cycle" do
      let(:old_recruitment_cycle) { create(:recruitment_cycle, :previous) }
      let(:new_provider) do
        create(:provider, recruitment_cycle: old_recruitment_cycle, provider_code: provider.provider_code)
      end
      let(:new_recruitment_cycle) do
        create(:recruitment_cycle, :next, providers: [new_provider])
      end

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

      it "copies over the partnerships" do
        service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)

        expect(mocked_copy_partnership_service).to have_received(:execute)
          .with(
            provider: provider,
            rolled_over_provider: new_provider,
            new_recruitment_cycle: new_recruitment_cycle,
          )
      end
    end

    it "assigns the new provider to organisation" do
      service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)

      expect(new_provider.organisation).to eq provider.organisation
    end

    it "assigns the new provider to users" do
      service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)

      expect(new_provider.users).to eq provider.users
    end

    it "copies over the ucas_preferences" do
      service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)

      compare_attrs = %w[
        type_of_gt12
        send_application_alerts
        application_alert_email
        gt12_response_destination
      ]
      expect(new_provider.ucas_preferences.attributes.slice(*compare_attrs))
        .to eq provider.ucas_preferences.attributes.slice(*compare_attrs)
    end

    it "copies over the contacts" do
      service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)

      compare_attrs = %w[name email telephone]
      expect(new_provider.contacts.map { |c| c.attributes.slice(*compare_attrs) })
        .to eq(provider.contacts.map { |c| c.attributes.slice(*compare_attrs) })
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
      output = service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)

      expect(output).to include(
        providers: 1,
        sites: 1,
        study_sites: 1,
        courses: 1,
        partnerships: 1,
        courses_failed: [],
        courses_skipped: [],
        study_sites_skipped: [],
      )
    end

    context "when site copying fails" do
      let(:failed_site_result) do
        Sites::CopyToProviderService::Result.new(
          success?: false,
          site: nil,
          error_message: "Site creation failed",
        )
      end

      it "tracks failed sites in the result" do
        allow(mocked_copy_site_service).to receive(:execute).and_return(failed_site_result)

        result = service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle)

        expect(result[:sites]).to eq(0)
        expect(result[:study_sites_skipped]).to contain_exactly(
          { site_code: site.code, reason: "Site creation failed" },
          { site_code: study_site.code, reason: "Site creation failed" },
        )
      end
    end

    context "provider is not rollable?" do
      let(:provider) do
        create(:provider,
               :with_users,
               sites: [site],
               study_sites: [study_site],
               contacts: contacts)
      end
      let(:draft_course_enrichment) { build(:course_enrichment) }
      let(:course_enrichments) { [draft_course_enrichment] }

      it "is not rollable" do
        expect(provider).not_to be_rollable
      end

      it "courses is not rollable" do
        provider.courses.each do |course|
          expect(course).not_to be_rollable
        end
      end

      context "with force as true" do
        subject do
          service.execute(provider: provider, new_recruitment_cycle: new_recruitment_cycle, course_codes: course_codes)
        end

        let(:force) { true }
        let(:course_codes) { nil }

        it "still copies the provider" do
          expect { subject }.to(change { new_recruitment_cycle.providers.count })
        end

        it "does not copy courses when course_codes is nil" do
          subject
          expect(mocked_copy_course_service).not_to have_received(:execute)
        end

        context "with course_codes as empty array" do
          let(:course_codes) { [] }

          it "still copies the provider" do
            expect { subject }.to(change { new_recruitment_cycle.providers.count })
          end

          it "does not copy courses" do
            subject
            expect(mocked_copy_course_service).not_to have_received(:execute)
          end
        end

        context "with specified course_codes" do
          let(:course_codes) { [course.course_code] }

          it "still copies the provider" do
            expect { subject }.to(change { new_recruitment_cycle.providers.count })
          end

          it "still copies the courses" do
            subject
            expect(mocked_copy_course_service).to have_received(:execute).with(course: course, new_provider: new_provider)
          end
        end

        context "with unknown specified course_codes" do
          let(:course_codes) { %w[B05S] }

          it "errors out with correct message" do
            expect { subject }.to raise_error("Error: discrepancy between courses found and provided course codes (0 vs 1)")
          end
        end
      end
    end
  end
end
