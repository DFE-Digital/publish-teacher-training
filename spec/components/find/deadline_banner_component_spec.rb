# frozen_string_literal: true

require 'rails_helper'

module Find
  describe DeadlineBannerComponent, type: :component do
    context 'when it is mid cycle' do
      it 'does not render' do
        Timecop.travel(CycleTimetable.first_deadline_banner - 1.hour) do
          result = render_inline(described_class.new(flash_empty: true))

          expect(result.text).to be_blank
        end
      end
    end

    context 'when find has reopened, but apply has not' do
      it 'renders the banner with information about when apply reopens' do
        Timecop.travel(CycleTimetable.find_opens + 1.hour) do
          apply_opens = CycleTimetable.apply_opens.to_fs(:day_and_month)
          previous_cycle_year = CycleTimetable.cycle_year_range(CycleTimetable.previous_year)
          cycle_year = CycleTimetable.cycle_year_range

          result = render_inline(described_class.new(flash_empty: true))
          expect(result.text).to include("Apply for courses from #{apply_opens}")
          expect(result.text).to include("The application deadline has passed for courses starting in the #{previous_cycle_year} academic year.")
          expect(result.text).to include("You can now search for courses starting in the #{cycle_year} academic year.")
          expect(result.text).to include("You can prepare applications for these courses, and from #{apply_opens} you will be able to submit your applications.")
        end
      end
    end

    context 'when it is after the first_deadline_banner and before the apply_deadline' do
      it 'renders the banner with information about the apply deadline' do
        Timecop.travel(CycleTimetable.first_deadline_banner + 1.hour) do
          result = render_inline(described_class.new(flash_empty: true))

          cycle_year_range = Find::CycleTimetable.cycle_year_range
          apply_deadline = Find::CycleTimetable.apply_deadline.to_fs(:govuk_date_and_time)
          expect(result.text).to include("The deadline for applying to courses starting in #{cycle_year_range} is #{apply_deadline}")
          expect(result.text).to include('Courses may fill up before then. Check course availability with the provider.')
        end
      end
    end

    context 'when it is after the apply_deadline and before the find_closes' do
      it 'renders the banner with information about the apply deadline' do
        Timecop.travel(CycleTimetable.apply_deadline + 1.hour) do
          cycle_year = CycleTimetable.cycle_year_range
          find_reopens = CycleTimetable.find_reopens.to_fs(:day_and_month)
          next_cycle_year = CycleTimetable.cycle_year_range(CycleTimetable.next_year)
          apply_reopens = CycleTimetable.apply_reopens.to_fs(:day_and_month)

          result = render_inline(described_class.new(flash_empty: true))

          expect(result.text).to include('The application deadline has passed')
          expect(result.text).to include("The application deadline has passed for courses starting in the #{cycle_year} academic year.")
          expect(result.text).to include("From #{find_reopens} you will be able to search for courses starting in the #{next_cycle_year} academic year.")
          expect(result.text).to include("From #{apply_reopens} you will be able to apply for these courses.")
        end
      end
    end

    context 'when find is down' do
      it 'does not render' do
        Timecop.travel(CycleTimetable.find_closes + 1.hour) do
          result = render_inline(described_class.new(flash_empty: true))

          expect(result.text).to be_blank
        end
      end
    end
  end
end
