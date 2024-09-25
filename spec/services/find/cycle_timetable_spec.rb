# frozen_string_literal: true

module Find
  require 'rails_helper'

  RSpec.describe CycleTimetable do
    let(:one_hour_before_find_opens) { described_class.find_opens - 1.hour }
    let(:one_hour_after_find_opens) { described_class.find_opens + 1.hour }
    let(:one_hour_before_first_deadline_banner) { described_class.first_deadline_banner - 1.hour }
    let(:one_hour_before_apply_deadline) { described_class.apply_deadline - 1.hour }
    let(:one_hour_after_apply_deadline) { described_class.apply_deadline + 1.hour }
    let(:one_hour_after_find_closes) { described_class.find_closes + 1.hour }
    let(:one_hour_after_find_reopens) { described_class.find_reopens + 1.hour }

    describe '.current_year' do
      it 'is 2021 if we are in the middle of the 2021 cycle' do
        Timecop.travel(Time.zone.local(2020, 10, 6, 10, 0, 0)) do
          expect(described_class.current_year).to eq(2021)
        end
      end

      it 'is 2022 if we are in the middle of the 2022 cycle' do
        Timecop.travel(Time.zone.local(2021, 10, 5, 10, 0, 0)) do
          expect(described_class.current_year).to eq(2022)
        end
      end

      context "We are in the middle of the 2021 cycle and the cycle switcher has been set to 'find has reopened'" do
        it 'is 2022' do
          allow(SiteSetting).to receive(:cycle_schedule).and_return(:today_is_after_find_opens)

          Timecop.travel(Time.zone.local(2020, 10, 6, 10, 0, 0)) do
            expect(described_class.current_year).to eq(2022)
          end
        end
      end
    end

    describe '.next_year' do
      it 'is 2022 if we are in the middle of the 2021 cycle' do
        Timecop.travel(Time.zone.local(2021, 1, 1, 12, 0, 0)) do
          expect(described_class.next_year).to eq(2022)
        end
      end

      it 'is 2023 if we are in the middle of the 2022 cycle' do
        Timecop.travel(Time.zone.local(2021, 11, 1, 12, 0, 0)) do
          expect(described_class.next_year).to eq(2023)
        end
      end
    end

    describe '.find_opens(year)' do
      context 'when no argument is passed' do
        it 'returns find_opens date for 2021' do
          Timecop.travel(Time.zone.local(2021, 1, 1, 12, 0, 0)) do
            expect(described_class.find_opens).to eq(Time.zone.local(2020, 10, 6, 9))
          end
        end
      end

      context 'when passing 2024 as argument' do
        it 'returns find_opens date for 2024' do
          Timecop.travel(Time.zone.local(2021, 11, 1, 12, 0, 0)) do
            expect(described_class.find_opens(2024)).to eq(Time.zone.local(2023, 10, 3, 9))
          end
        end
      end
    end

    describe '.preview_mode?' do
      it 'returns true when it is after the Apply deadline but before Find closes' do
        Timecop.travel(Time.zone.local(2021, 9, 21, 19, 0, 0)) do
          expect(described_class.preview_mode?).to be true
        end
      end

      it 'returns false before the Apply deadline' do
        Timecop.travel(Time.zone.local(2021, 9, 21, 17, 0, 0)) do
          expect(described_class.preview_mode?).to be false
        end
      end

      it 'returns false when Find has reopened' do
        Timecop.travel(Time.zone.local(2021, 10, 5, 10, 0, 0)) do
          expect(described_class.preview_mode?).to be false
        end
      end
    end

    describe '.find_down?' do
      it 'returns true when it is after Find closes and before it reopens' do
        Timecop.travel(Time.zone.local(2021, 10, 5, 1, 0, 0)) do
          expect(described_class.find_down?).to be true
        end
      end

      it 'returns false before Find closes' do
        Timecop.travel(Time.zone.local(2021, 9, 21, 17, 0, 0)) do
          expect(described_class.find_down?).to be false
        end
      end

      it 'returns false when Find has reopened' do
        Timecop.travel(Time.zone.local(2021, 10, 5, 10, 0, 0)) do
          expect(described_class.find_down?).to be false
        end
      end
    end

    describe '.mid_cycle??' do
      it 'returns true after Find has opened' do
        Timecop.travel(Time.zone.local(2021, 10, 5, 10, 0, 0)) do
          expect(described_class.mid_cycle?).to be true
        end
      end

      it 'returns false after the apply_deadline' do
        Timecop.travel(Time.zone.local(2021, 9, 21, 19, 0, 0)) do
          expect(described_class.mid_cycle?).to be false
        end
      end

      context 'when current_cycle_schedule returns `:today_is_after_find_opens`' do
        it 'returns true' do
          allow(described_class).to receive(:current_cycle_schedule).and_return(:today_is_after_find_opens)
          expect(described_class.mid_cycle?).to be true
        end
      end
    end

    describe '.show_apply_deadline_banner?' do
      it 'returns true when it is after the first_deadline_banner and before the apply_deadline' do
        Timecop.travel(Time.zone.local(2024, 7, 30, 19, 0, 0)) do
          expect(described_class.show_apply_deadline_banner?).to be true
        end
      end

      it 'returns false before the after the apply_deadline' do
        Timecop.travel(Time.zone.local(2021, 9, 21, 19, 0, 0)) do
          expect(described_class.show_apply_deadline_banner?).to be false
        end
      end

      it 'returns false before the first_deadline_banner' do
        Timecop.travel(Time.zone.local(2021, 7, 7, 12, 0, 0)) do
          expect(described_class.show_apply_deadline_banner?).to be false
        end
      end
    end

    describe '.show_cycle_closed_banner?' do
      it 'returns true when it is after the apply_deadline and before Find closes' do
        Timecop.travel(Time.zone.local(2021, 9, 21, 19, 0, 0)) do
          expect(described_class.show_cycle_closed_banner?).to be true
        end
      end

      it 'returns false after Find closes' do
        Timecop.travel(Time.zone.local(2021, 10, 5, 1, 0, 0)) do
          expect(described_class.show_cycle_closed_banner?).to be false
        end
      end

      it 'returns false before the apply_deadline' do
        Timecop.travel(Time.zone.local(2021, 9, 21, 17, 0, 0)) do
          expect(described_class.show_cycle_closed_banner?).to be false
        end
      end
    end

    describe '.cycle_year_range' do
      it 'returns the correctly formatted value' do
        Timecop.travel(Time.zone.local(2021, 9, 7, 17, 0, 0)) do
          expect(described_class.cycle_year_range).to eq('2021 to 2022')
        end
      end
    end

    describe '.next_cycle_year_range' do
      it 'returns the correctly formatted value' do
        Timecop.travel(Time.zone.local(2021, 9, 7, 17, 0, 0)) do
          expect(described_class.next_cycle_year_range).to eq('2022 to 2023')
        end
      end
    end
  end
end
