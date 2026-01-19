# frozen_string_literal: true

# PostsControllerのprivateメソッドをまとめるConcern（ハブ）
# - RuboCopの行数制限回避のため、用途ごとにConcernを分割してincludeする
module PostsControllerSupport
  extend ActiveSupport::Concern

  include PostsControllerPhotos
  include PostsControllerLineNotify
end
