class UserPermission < ApplicationRecord
  belongs_to :user
  belongs_to :provider
end
