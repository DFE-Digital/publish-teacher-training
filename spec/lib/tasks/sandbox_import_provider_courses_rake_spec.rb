# frozen_string_literal: true

require "rails_helper"
require "rake"

describe "sandbox:import_provider_courses" do
  Rails.application.load_tasks if Rake::Task.tasks.empty?

  subject(:run_task) { Rake::Task["sandbox:import_provider_courses"].invoke(*args) }

  let(:args) { %w[c55 2027] }
  let(:environment) { "sandbox" }

  before do
    Rake::Task["sandbox:import_provider_courses"].reenable
    allow(Rails).to receive(:env).and_return(ActiveSupport::EnvironmentInquirer.new(environment))
    allow(Sandbox::ImportProviderCourses).to receive(:call)
  end

  it "does a dry run by default" do
    run_task

    expect(Sandbox::ImportProviderCourses).to have_received(:call).with(provider_code: "C55", year: 2027, confirm: false)
  end

  context "when confirmed" do
    let(:args) { %w[C55 2027 true] }

    it "commits the import" do
      run_task

      expect(Sandbox::ImportProviderCourses).to have_received(:call).with(provider_code: "C55", year: 2027, confirm: true)
    end
  end

  context "when confirm is anything but true" do
    let(:args) { %w[C55 2027 yes] }

    it "does a dry run" do
      run_task

      expect(Sandbox::ImportProviderCourses).to have_received(:call).with(provider_code: "C55", year: 2027, confirm: false)
    end
  end

  context "when the year isn't a number" do
    let(:args) { %w[C55 next] }

    it "fails without importing" do
      expect { run_task }.to raise_error(ArgumentError)
      expect(Sandbox::ImportProviderCourses).not_to have_received(:call)
    end
  end

  context "when the import aborts" do
    before do
      allow(Sandbox::ImportProviderCourses).to receive(:call)
        .and_raise(Sandbox::ImportProviderCourses::Abort, "There is no 2027 recruitment cycle here")
    end

    it "exits with the reason" do
      expect { run_task }
        .to raise_error(SystemExit)
        .and output("There is no 2027 recruitment cycle here\n").to_stderr
    end
  end

  context "when in production" do
    let(:environment) { "production" }

    it "refuses to run" do
      expect { run_task }.to raise_error("Can only be run in sandbox or development")
      expect(Sandbox::ImportProviderCourses).not_to have_received(:call)
    end
  end
end
