# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Find switcher", service: :find, type: :request do
  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("ENABLE_SWITCHER").and_return("1")
  end

  describe "POST /cycles" do
    it "keeps the current schedule when the submitted phase is not known" do
      SiteSetting.set(name: "cycle_schedule", value: "apply_open")

      post find_switch_cycle_schedule_path,
           params: { find_change_cycle_form: { cycle_schedule_name: "not_a_phase" } }

      expect(Find::CycleTimetable.current_cycle_schedule).to eq(:apply_open)
    end

    it "switches the cycle and deadline banner in the database and mirrors them to Redis" do
      post find_switch_cycle_schedule_path,
           params: { find_change_cycle_form: { cycle_schedule_name: "apply_open", deadline_banner: "1" } }

      expect(SiteSetting.pluck(:name, :value)).to contain_exactly(%w[cycle_schedule apply_open], %w[deadline_banner true])
      expect(RedisClient.current.get("cycle_schedule")).to eq("apply_open")
      expect(RedisClient.current.get("deadline_banner")).to eq("true")

      post find_switch_cycle_schedule_path,
           params: { find_change_cycle_form: { cycle_schedule_name: "real" } }

      Current.reset
      expect(Find::CycleTimetable.current_cycle_schedule).to eq(:real)
      expect(SiteSetting.deadline_banner?).to be(false)
    end
  end
end
