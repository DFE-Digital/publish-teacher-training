class InitializeStateForUsers < ActiveRecord::Migration[5.2]
  def up
    User.find_each do |user|
      user.activated! if user.accept_terms_date_utc.present?
    end
  end

  def down
    User.find_each do |user|
      next unless user.active?

      user.update(
        accept_terms_date_utc: Time.current,
        aasm_state:            'new'
      )
    end
  end
end
