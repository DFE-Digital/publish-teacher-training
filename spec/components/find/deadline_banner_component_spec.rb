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
          result = render_inline(described_class.new(flash_empty: true))

          expect(result.text).to include("Courses starting in the #{CycleTimetable.cycle_year_range} academic year are closed")
          expect(result.text).not_to include('Courses can fill up at any time, so you should apply as soon as you can.')
          expect(result.text).not_to include("If your application did not lead to a place and you’re applying again, apply no later than 6pm on #{CycleTimetable.apply_deadline.strftime('%e %B %Y')}.")
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
