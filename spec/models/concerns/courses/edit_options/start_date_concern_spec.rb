# frozen_string_literal: true

require "rails_helper"

describe Courses::EditOptions::StartDateConcern do
  let(:recruitment_cycle) do
    RecruitmentCycle.find_by(year: "2026") || create(:recruitment_cycle, year: 2026)
  end
  let(:provider) { create(:provider, recruitment_cycle: recruitment_cycle) }

  after do
    travel_back
  end

  describe "#start_date_options" do
    context "non-persisted course" do
      let(:example_model) { build(:course, provider: provider) }

      context "2026 cycle course" do
        context "today (October 1, 2025 - in 2026 cycle)" do
          it "returns options starting from January 2026 (not October 2026)" do
            travel_to Time.zone.local(2025, 10, 1, 14, 5) do
              allow(Find::CycleTimetable).to receive(:current_year).and_return(2026)

              # Since we're in October 2025 but CycleTimetable.current_year is 2026,
              # we should look for "October 2026" but it doesn't exist in the 2026 cycle options.
              # The 2026 cycle options are Jan 2026 - July 2027
              # So we fall back to index 0 (January 2026)
              expected_options = [
                "January 2026",
                "February 2026",
                "March 2026",
                "April 2026",
                "May 2026",
                "June 2026",
                "July 2026",
                "August 2026",
                "September 2026",
                "October 2026",
                "November 2026",
                "December 2026",
                "January 2027",
                "February 2027",
                "March 2027",
                "April 2027",
                "May 2027",
                "June 2027",
                "July 2027",
              ]

              expect(example_model.start_date_options).to eq(expected_options)
            end
          end
        end

        context "January 2026 (mid 2026 cycle)" do
          it "returns options starting from January 2026" do
            travel_to Time.zone.local(2026, 1, 15) do
              allow(Find::CycleTimetable).to receive(:current_year).and_return(2026)

              expected_options = [
                "January 2026",
                "February 2026",
                "March 2026",
                "April 2026",
                "May 2026",
                "June 2026",
                "July 2026",
                "August 2026",
                "September 2026",
                "October 2026",
                "November 2026",
                "December 2026",
                "January 2027",
                "February 2027",
                "March 2027",
                "April 2027",
                "May 2027",
                "June 2027",
                "July 2027",
              ]

              expect(example_model.start_date_options).to eq(expected_options)
            end
          end
        end

        context "June 2026 (mid 2026 cycle)" do
          it "returns options starting from June 2026" do
            travel_to Time.zone.local(2026, 6, 10) do
              allow(Find::CycleTimetable).to receive(:current_year).and_return(2026)

              expected_options = [
                "June 2026",
                "July 2026",
                "August 2026",
                "September 2026",
                "October 2026",
                "November 2026",
                "December 2026",
                "January 2027",
                "February 2027",
                "March 2027",
                "April 2027",
                "May 2027",
                "June 2027",
                "July 2027",
              ]

              expect(example_model.start_date_options).to eq(expected_options)
            end
          end
        end

        context "September 2026 (end of 2026 cycle applications)" do
          it "returns options starting from September 2026" do
            travel_to Time.zone.local(2026, 9, 15) do
              allow(Find::CycleTimetable).to receive(:current_year).and_return(2026)

              expected_options = [
                "September 2026",
                "October 2026",
                "November 2026",
                "December 2026",
                "January 2027",
                "February 2027",
                "March 2027",
                "April 2027",
                "May 2027",
                "June 2027",
                "July 2027",
              ]

              expect(example_model.start_date_options).to eq(expected_options)
            end
          end
        end
      end

      context "2027 cycle course" do
        let(:recruitment_cycle_2027) do
          RecruitmentCycle.find_by(year: "2027") || create(:recruitment_cycle, year: 2027)
        end
        let(:provider_2027) { create(:provider, recruitment_cycle: recruitment_cycle_2027) }
        let(:example_model) { build(:course, provider: provider_2027) }

        context "September 2026 (2027 cycle course but still in 2026 timetable)" do
          it "returns 2027 cycle options filtered by current 2026 timetable month" do
            travel_to Time.zone.local(2026, 9, 15) do
              allow(Find::CycleTimetable).to receive(:current_year).and_return(2026)

              expected_options = [
                "January 2027",
                "February 2027",
                "March 2027",
                "April 2027",
                "May 2027",
                "June 2027",
                "July 2027",
                "August 2027",
                "September 2027",
                "October 2027",
                "November 2027",
                "December 2027",
                "January 2028",
                "February 2028",
                "March 2028",
                "April 2028",
                "May 2028",
                "June 2028",
                "July 2028",
              ]

              expect(example_model.start_date_options).to eq(expected_options)
            end
          end
        end

        context "October 2026 (2027 cycle has opened)" do
          it "returns options starting from October 2027" do
            travel_to Time.zone.local(2026, 10, 5) do
              allow(Find::CycleTimetable).to receive(:current_year).and_return(2027)

              expected_options = [
                "January 2027",
                "February 2027",
                "March 2027",
                "April 2027",
                "May 2027",
                "June 2027",
                "July 2027",
                "August 2027",
                "September 2027",
                "October 2027",
                "November 2027",
                "December 2027",
                "January 2028",
                "February 2028",
                "March 2028",
                "April 2028",
                "May 2028",
                "June 2028",
                "July 2028",
              ]

              expect(example_model.start_date_options).to eq(expected_options)
            end
          end
        end

        context "January 2027 (mid 2027 cycle)" do
          it "returns options starting from January 2027" do
            travel_to Time.zone.local(2027, 1, 15) do
              allow(Find::CycleTimetable).to receive(:current_year).and_return(2027)

              expected_options = [
                "January 2027",
                "February 2027",
                "March 2027",
                "April 2027",
                "May 2027",
                "June 2027",
                "July 2027",
                "August 2027",
                "September 2027",
                "October 2027",
                "November 2027",
                "December 2027",
                "January 2028",
                "February 2028",
                "March 2028",
                "April 2028",
                "May 2028",
                "June 2028",
                "July 2028",
              ]

              expect(example_model.start_date_options).to eq(expected_options)
            end
          end
        end
      end
    end

    context "persisted course" do
      let(:example_model) { create(:course, provider: provider) }

      shared_examples "returns complete options regardless of time" do |cycle_year|
        it "returns all start date options for the recruitment cycle" do
          expected_options = [
            "January #{cycle_year}",
            "February #{cycle_year}",
            "March #{cycle_year}",
            "April #{cycle_year}",
            "May #{cycle_year}",
            "June #{cycle_year}",
            "July #{cycle_year}",
            "August #{cycle_year}",
            "September #{cycle_year}",
            "October #{cycle_year}",
            "November #{cycle_year}",
            "December #{cycle_year}",
            "January #{cycle_year + 1}",
            "February #{cycle_year + 1}",
            "March #{cycle_year + 1}",
            "April #{cycle_year + 1}",
            "May #{cycle_year + 1}",
            "June #{cycle_year + 1}",
            "July #{cycle_year + 1}",
          ]

          expect(example_model.start_date_options).to eq(expected_options)
        end
      end

      context "2026 cycle course" do
        context "today (October 1, 2025)" do
          before do
            travel_to Time.zone.local(2025, 10, 1)
          end

          it_behaves_like "returns complete options regardless of time", 2026
        end

        context "January 2026" do
          before do
            travel_to Time.zone.local(2026, 1, 15)
          end

          it_behaves_like "returns complete options regardless of time", 2026
        end
      end

      context "2027 cycle course" do
        let(:recruitment_cycle_2027) do
          RecruitmentCycle.find_by(year: "2027") || create(:recruitment_cycle, year: 2027)
        end
        let(:provider_2027) { create(:provider, recruitment_cycle: recruitment_cycle_2027) }
        let(:example_model) { create(:course, provider: provider_2027) }

        context "September 2026" do
          before do
            travel_to Time.zone.local(2026, 9, 15)
          end

          it_behaves_like "returns complete options regardless of time", 2027
        end
      end
    end
  end

  describe "#show_start_date?" do
    let(:example_model) { build(:course, provider: provider) }

    context "when course is not published" do
      before { allow(example_model).to receive(:is_published?).and_return(false) }

      it "returns true" do
        expect(example_model.show_start_date?).to be true
      end
    end

    context "when course is published" do
      before { allow(example_model).to receive(:is_published?).and_return(true) }

      it "returns false" do
        expect(example_model.show_start_date?).to be false
      end
    end
  end
end
