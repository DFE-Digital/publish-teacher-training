class AddIsSendToCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :course, :is_send, :boolean, default: false

    say_with_time "Ensuring Courses have `is_send` set" do
      Course.joins(:subjects).where(subject: { subject_code: "U3" }).update_all(is_send: true)
    end
  end
end
