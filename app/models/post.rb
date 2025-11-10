class Post < ApplicationRecord
  belongs_to :album
  belongs_to :user
  belongs_to :child
end
