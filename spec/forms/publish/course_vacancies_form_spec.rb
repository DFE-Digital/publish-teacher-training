# frozen_string_literal: true

require "rails_helper"

module Publish
  describe CourseVacanciesForm, type: :model do
    let(:params) { {} }
    let(:provider) { build(:provider, sites: [site]) }
    let(:site) { build(:site) }
    let(:findable) { build(:site_status, :findable, site:) }
    let(:study_mode) { :full_time }
    let(:course) { create(:course, study_mode, provider:, site_statuses:) }
    let(:site_statuses) { [findable] }

    subject { described_class.new(course, params:) }

    describe "validations" do
      before { subject.valid? }

      context "course has no vacancies" do
        let(:site_statuses) { [] }

        it "validates :change_vacancies_confirmation" do
          expect(subject.errors[:change_vacancies_confirmation]).to include(I18n.t("activemodel.errors.models.publish/course_vacancies_form.attributes.change_vacancies_confirmation.confirm_reopen_application"))
        end
      end

      context "course has vacancies" do
        it "validates :change_vacancies_confirmation" do
          expect(subject.errors[:change_vacancies_confirmation]).to include(I18n.t("activemodel.errors.models.publish/course_vacancies_form.attributes.change_vacancies_confirmation.confirm_close_application"))
        end
      end
    end

    describe "#save!" do
      let(:vacancy_statuses) { [{ id:, status: }] }

      context "multi sites" do
        let(:with_any_vacancy) { build(:site_status, :with_any_vacancy, site:) }
        let(:site_statuses) { [findable, with_any_vacancy] }
        let(:id) { with_any_vacancy.id }

        let(:params) { { site_statuses_attributes: { "0": { id: with_any_vacancy.id } }, has_vacancies: false } }
        let(:status) { "no_vacancies" }

        context "with change_vacancies_confirmation as no_vacancies_confirmation" do
          let(:change_vacancies_confirmation) { "no_vacancies_confirmation" }
          let(:status) { "no_vacancies" }

          it "calls the course vacancies updated notification service" do
            expect(NotificationService::CourseVacanciesUpdated).to receive(:call)
            .with(course:, vacancy_statuses:)
            subject.save!
          end
        end
      end

      context "single site" do
        let(:params) { { change_vacancies_confirmation: } }
        let(:id) { findable.id }

        context "with change_vacancies_confirmation as no_vacancies_confirmation" do
          let(:change_vacancies_confirmation) { "no_vacancies_confirmation" }
          let(:status) { "no_vacancies" }

          it "calls the course vacancies updated notification service" do
            expect(NotificationService::CourseVacanciesUpdated).to receive(:call)
            .with(course:, vacancy_statuses:)
            subject.save!
          end
        end

        context "with change_vacancies_confirmation as has_vacancies_confirmation" do
          let(:change_vacancies_confirmation) { "has_vacancies_confirmation" }

          context "with full time study mode" do
            let(:status) { "full_time_vacancies" }

            it "calls the course vacancies updated notification service" do
              expect(NotificationService::CourseVacanciesUpdated).to receive(:call)
              .with(course:, vacancy_statuses:)
              subject.save!
            end
          end

          context "with part time study mode" do
            let(:study_mode) { :part_time }
            let(:site_statuses) { [findable_with_part_time_vacancies] }
            let(:status) { "part_time_vacancies" }
            let(:id) { findable_with_part_time_vacancies.id }
            let(:findable_with_part_time_vacancies) { build(:site_status, :part_time_vacancies, :findable, site:) }

            let(:updated_site_names) { provider.sites.map(&:location_name) }

            it "calls the course vacancies updated notification service" do
              expect(NotificationService::CourseVacanciesUpdated).to receive(:call)
              .with(course:, vacancy_statuses:)
              subject.save!
            end
          end
        end
      end
    end
  end
end
