require "spec_helper"

describe VacancyStatusDeterminationService do
  describe ".call" do
    let(:vacancy_status_full_time) { "0" }
    let(:vacancy_status_part_time) { "0" }

    subject do
      described_class.call(
        vacancy_status_full_time: vacancy_status_full_time,
        vacancy_status_part_time: vacancy_status_part_time,
        course: course,
      )
    end

    context "with a full time or part time course" do
      let(:course) { build_stubbed(:course, :full_time_or_part_time) }

      context "with a full time and part time vacancies" do
        let(:vacancy_status_full_time) { "1" }
        let(:vacancy_status_part_time) { "1" }

        it { is_expected.to eq "both_full_time_and_part_time_vacancies" }
      end

      context "with a full time vacancy" do
        let(:vacancy_status_full_time) { "1" }

        it { is_expected.to eq "full_time_vacancies" }
      end

      context "with a part time vacancy" do
        let(:vacancy_status_part_time) { "1" }

        it { is_expected.to eq "part_time_vacancies" }
      end

      context "with no vacancies" do
        it { is_expected.to eq "no_vacancies" }
      end
    end

    context "with a full time course" do
      let(:course) { build_stubbed(:course, :full_time) }

      context "with a full time vacancy" do
        let(:vacancy_status_full_time) { "1" }

        it { is_expected.to eq "full_time_vacancies" }
      end

      context "with no vacancy" do
        it { is_expected.to eq "no_vacancies" }
      end
    end

    context "with a part time course" do
      let(:course) { build_stubbed(:course, :part_time) }

      context "with a part time vacancy" do
        let(:vacancy_status_part_time) { "1" }

        it { is_expected.to eq "part_time_vacancies" }
      end

      context "with no vacancies" do
        it { is_expected.to eq "no_vacancies" }
      end
    end
  end
end
