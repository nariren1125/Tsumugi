class User < ApplicationRecord
  belongs_to :family_group, optional: true
end
