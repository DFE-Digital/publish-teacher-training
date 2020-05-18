require "rails_helper"

describe PublishReportingService do
  let(:expected) do
    {
      users: {
        total: {
          all: 666,
          active_users: 600,
          non_active_users: 66,
          active_users_last_30_days: 60,
        },
      },
      providers: {
        total: {
          all: 1000,
          providers_with_non_active_users: 990,
          providers_with_active_users: 10,
        },
        with_1_active_users: 1,
        with_2_active_users: 2,
        with_3_active_users: 0,
        with_4_active_users: 4,
        with_more_than_5_active_users: 6,
      },
      courses: {
        total_updated_last_30_days: 100,
        updated_non_findable_last_30_days: 40,
        updated_findable_last_30_days: 60,
        updated_open_courses_last_30_days: 35,
        updated_closed_courses_last_30_days: 25,
        created_last_30_days: 10,
      },
    }
  end

  let(:recruitment_cycle_scope) do
    instance_double(RecruitmentCycle)
  end
  let(:courses_scope) { class_double(Course) }
  let(:providers_scope) { double(Provider) }
  let(:providers_active_user_scope) { class_double(Provider) }
  let(:grouped_providers_active_user_scope) { class_double(Provider) }
  let(:ordered_grouped_providers_active_user_scope) { class_double(Provider) }

  let(:grouped_providers_with_x_active_users_scope) { class_double(Provider) }

  let(:providers_active_user_distinct_count) { 10 }

  let(:counted_ordered_grouped_providers_active_user) {
    {
      1 => 1,
      2 => 2,
      3 => 2,
      4 => 4,
      5 => 4,
      6 => 4,
      7 => 4,
      8 => 6,
      9 => 6,
      10 => 6,
      11 => 6,
      12 => 6,
      13 => 6,
    }
  }
  let(:providers_count) { 1000 }
  let(:courses_changed_at_since_count) { 100 }
  let(:courses_findable_count) { 60 }
  let(:open_courses_count) { 35 }
  let(:closed_courses_count) { 25 }

  let(:courses_created_at_since_count) { 10 }


  let(:courses_changed_at_since_scope) { class_double(Course) }
  let(:courses_findable_scope) { class_double(Course) }
  let(:open_courses_scope) { class_double(Course) }
  let(:closed_courses_scope) { class_double(Course) }


  describe ".call" do
    describe "when scope is passed" do
      before do
        allow(recruitment_cycle_scope).to receive(:courses).and_return(courses_scope)
        allow(recruitment_cycle_scope).to receive(:providers).and_return(providers_scope)
      end
      subject { described_class.call(recruitment_cycle_scope: recruitment_cycle_scope) }

      it "applies the scopes" do
        expect(User).to receive_message_chain(:count).and_return(666)
        expect(User).to receive_message_chain(:active, :count).and_return(600)
        expect(User).to receive_message_chain(:active, :last_login_since, :count).and_return(60)

        expect(providers_scope).to receive_message_chain(:with_users).and_return(providers_active_user_scope)
        expect(providers_active_user_scope).to receive_message_chain(:distinct, :count) .and_return(providers_active_user_distinct_count)

        expect(providers_active_user_scope).to receive_message_chain(:group).with(:id) .and_return(grouped_providers_active_user_scope)
        expect(grouped_providers_active_user_scope).to receive_message_chain(:order).with(count_id: :desc) .and_return(ordered_grouped_providers_active_user_scope)

        expect(ordered_grouped_providers_active_user_scope).to receive_message_chain(:count).with(:id) .and_return(counted_ordered_grouped_providers_active_user)

        expect(providers_scope).to receive_message_chain(:count).and_return(providers_count)

        expect(courses_scope).to receive_message_chain(:changed_at_since).and_return(courses_changed_at_since_scope)
        expect(courses_changed_at_since_scope).to receive_message_chain(:findable, :distinct).and_return(courses_findable_scope)
        expect(courses_findable_scope).to receive_message_chain(:with_vacancies).and_return(open_courses_scope)
        expect(courses_findable_scope).to receive_message_chain(:where, :not).with(id: open_courses_scope).and_return(closed_courses_scope)
        expect(courses_changed_at_since_scope).to receive_message_chain(:count).and_return(courses_changed_at_since_count)
        expect(courses_findable_scope).to receive_message_chain(:count).and_return(courses_findable_count)
        expect(open_courses_scope).to receive_message_chain(:count).and_return(open_courses_count)
        expect(closed_courses_scope).to receive_message_chain(:count).and_return(closed_courses_count)

        expect(courses_scope).to receive_message_chain(:created_at_since, :count).and_return(courses_created_at_since_count)

        expect(subject).to eq(expected)
      end
    end
  end
end
