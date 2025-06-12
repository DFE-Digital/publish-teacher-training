class Authentication < ApplicationRecord
  belongs_to :authenticable, polymorphic: true
end
