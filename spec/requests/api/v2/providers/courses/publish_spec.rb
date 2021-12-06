require "rails_helper"

describe "Publish API v2", type: :request do
  let(:user) { create(:user) }
  let(:provider) { create :provider, users: [user] }
  let(:accredited_body) { create :provider, :accredited_body }
  let(:payload) { { email: user.email } }
  let(:credentials) { encode_to_credentials(payload) }

  describe "POST publish" do
    let(:status) { 200 }
    let(:publish_path) do
      "/api/v2/recruitment_cycles/#{provider.recruitment_cycle.year}/providers/#{provider.provider_code}" +
        "/courses/#{course.course_code}/publish"
    end

    let(:enrichment) { build(:course_enrichment, :initial_draft) }
    let(:site_status) { build(:site_status, :new) }
    let(:dfe_subject) { find_or_create(:primary_subject, :primary) }
    let(:course) {
      create(:course,
             :with_gcse_equivalency,
             provider: provider,
             accredited_body_code: accredited_body.provider_code,
             site_statuses: [site_status],
             enrichments: [enrichment],
             subjects: [dfe_subject])
    }

    subject do
      post publish_path,
           headers: { "HTTP_AUTHORIZATION" => credentials },
           params: {
             _jsonapi: {
               data: {
                 attributes: {},
                 type: "course",
               },
             },
           }
      response
    end

    include_examples "Unauthenticated, unauthorised, or not accepted T&Cs"

    context "when course and provider is not related" do
      let(:course) { create(:course) }

      it { is_expected.to have_http_status(:not_found) }
    end

    context "an unpublished course with a draft enrichment" do
      let(:enrichment) { build(:course_enrichment, :initial_draft) }
      let(:site_status) { build(:site_status, :findable) }
      let(:dfe_subjects) { [find_or_create(:primary_subject, :primary_with_mathematics)] }
      let!(:course) do
        create(:course,
               :with_gcse_equivalency,
               level: "primary",
               provider: provider,
               accredited_body_code: accredited_body.provider_code,
               site_statuses: [site_status],
               enrichments: [enrichment],
               subjects: dfe_subjects,
               age: 17.days.ago)
      end

      before do
        Timecop.freeze
      end

      after do
        Timecop.return
      end

      context "in the current cycle" do
        it "publishes a course" do
          perform_enqueued_jobs do
            expect(subject).to have_http_status(:success)
          end

          expect(course.reload.site_statuses.first).to be_status_running
          expect(course.site_statuses.first).to be_published_on_ucas
          expect(course.enrichments.first).to be_published
          expect(course.enrichments.first.updated_by_user_id).to eq user.id
          expect(course.enrichments.first.updated_at).to be_within(1.second).of Time.now.utc
          expect(course.enrichments.first.last_published_timestamp_utc).to be_within(1.second).of Time.now.utc
          expect(course.changed_at).to be_within(1.second).of Time.now.utc
        end
      end

      context "in the next cycle" do
        let(:provider) { create :provider, :next_recruitment_cycle, users: [user] }

        it "publishes a course" do
          perform_enqueued_jobs do
            expect(subject).to have_http_status(:success)
          end

          expect(course.reload.site_statuses.first).to be_status_running
          expect(course.site_statuses.first).to be_published_on_ucas
          expect(course.enrichments.first).to be_published
          expect(course.enrichments.first.updated_by_user_id).to eq user.id
          expect(course.enrichments.first.updated_at).to be_within(1.second).of Time.now.utc
          expect(course.enrichments.first.last_published_timestamp_utc).to be_within(1.second).of Time.now.utc
          expect(course.changed_at).to be_within(1.second).of Time.now.utc
        end
      end

      context "with a new site_status" do
        let(:site_status) { build(:site_status, :new) }

        it "Successfully publishes the course" do
          perform_enqueued_jobs do
            expect(subject).to have_http_status(:success)
          end

          expect(course.reload.site_statuses.first).to be_status_running
          expect(course.site_statuses.first).to be_published_on_ucas
          expect(course.enrichments.first).to be_published
          expect(course.enrichments.first.updated_by_user_id).to eq user.id
          expect(course.enrichments.first.updated_at).to be_within(1.second).of Time.now.utc
          expect(course.enrichments.first.last_published_timestamp_utc).to be_within(1.second).of Time.now.utc
          expect(course.changed_at).to be_within(1.second).of Time.now.utc
        end
      end
    end

    describe "failed validation" do
      let(:json_data) { JSON.parse(subject.body)["errors"] }

      context "no enrichments, sites and subjects" do
        let(:course) { create(:course, provider: provider, enrichments: [], site_statuses: []) }

        it { is_expected.to have_http_status(:unprocessable_entity) }

        it "has validation errors" do
          expect(json_data.map { |error| error["detail"] }).to match_array([
            "Select at least one location for this course",
            "Enter details about this course",
            "Enter details about school placements",
            "Enter a course length",
            "Enter details about the salary for this course",
            "Enter GCSE requirements",
          ])
        end
      end

      context "fee type based course" do
        let(:course) do
          create(:course, :fee_type_based,
                 provider: provider,
                 enrichments: [invalid_enrichment],
                 site_statuses: [site_status])
        end

        context "invalid enrichment with invalid content lack_presence fields" do
          let(:invalid_enrichment) { create(:course_enrichment, :without_content) }

          it { is_expected.to have_http_status(:unprocessable_entity) }

          it "has validation error details" do
            expect(json_data.map { |error| error["detail"] }).to match_array([
              "Enter details about this course",
              "Enter details about school placements",
              "Enter a course length",
              "Enter details about the fee for UK and EU students",
              "Enter GCSE requirements",
            ])
          end

          it "has validation error pointers" do
            expect(json_data.map { |error| error["source"]["pointer"] }).to match_array([
              "/data/attributes/about_course",
              "/data/attributes/how_school_placements_work",
              "/data/attributes/course_length",
              "/data/attributes/fee_uk_eu",
              nil,
            ])
          end
        end
      end

      context "salary type based course" do
        let(:course) {
          create(:course, :salary_type_based,
                 provider: provider,
                 enrichments: [invalid_enrichment],
                 site_statuses: [site_status])
        }

        context "invalid enrichment with invalid content lack_presence fields" do
          let(:invalid_enrichment) { create(:course_enrichment, :without_content) }

          it { is_expected.to have_http_status(:unprocessable_entity) }

          it "has validation errors" do
            expect(json_data.map { |error| error["detail"] }).to match_array([
              "Enter details about this course",
              "Enter details about school placements",
              "Enter a course length",
              "Enter details about the salary for this course",
              "Enter GCSE requirements",
            ])
          end
        end
      end

      context "an inconsistent course and site status" do
        let(:course) {
          create(:course,
                 provider: provider,
                 study_mode: "full_time",
                 enrichments: [enrichment],
                 site_statuses: [build(:site_status, :new, :full_time_vacancies)])
        }

        before do
          course.update_attribute(:study_mode, "part_time")
        end

        it "raises an error" do
          expect { subject }.to(raise_error(
                                  RuntimeError,
                                  "Site status invalid on course #{provider.provider_code}/#{course.course_code}: Vac status (full_time_vacancies) must be consistent with course study mode part_time",
                                ))
        end
      end

      context "accredited body does not exist in current recruitment cycle" do
        let(:accredited_body) { create(:provider, :accredited_body, :discarded) }
        let(:enrichment) { build(:course_enrichment, :initial_draft) }
        let(:site_status) { build(:site_status, :findable) }
        let(:dfe_subjects) { [find_or_create(:primary_subject, :primary_with_mathematics)] }
        let!(:course) do
          create(:course,
                 :with_gcse_equivalency,
                 level: "primary",
                 provider: provider,
                 accredited_body_code: accredited_body.provider_code,
                 site_statuses: [site_status],
                 enrichments: [enrichment],
                 subjects: dfe_subjects,
                 age: 17.days.ago)
        end

        it { is_expected.to have_http_status(:unprocessable_entity) }

        it "has validation errors" do
          expect(json_data.map { |error| error["detail"] }).to match_array([
            "The Accredited Body #{accredited_body.provider_code} does not exist in this cycle",
          ])
        end
      end
    end
  end
end
