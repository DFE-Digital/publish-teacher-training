class InitialiseStateForUsers < ActiveRecord::Migration[5.2]
  def up
    User.update_all(state: User.aasm.initial_state)
  end

  def down
    User.find_each do |user|
      next unless user.new?

      user.update(state: '')
    end
  end
end
