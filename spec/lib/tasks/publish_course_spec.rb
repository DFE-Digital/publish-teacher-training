# frozen_string_literal: true

require 'rails_helper'
require 'rake'

describe 'publish_give_course' do
  subject do
    Rake::Task['app:publish_course'].invoke(course.uuid, user.email)
  end

  let(:uuid) { 'b39fe8fe-7cc5-42b8-a06f-d4461b7eb84e' }
  let(:course) { create(:course, :publishable, uuid:) }
  let!(:user) { create(:user, :admin) }

  Rails.application.load_tasks if Rake::Task.tasks.empty?

  it 'calls Courses::PublishService service' do
    service = Courses::PublishService.new(course:, user:)
    allow(Courses::PublishService).to receive(:new).and_return(service)
    allow(service).to receive(:call).and_call_original
    expect { subject }.to change(course, :published?).from(false).to(true)
  end
end
