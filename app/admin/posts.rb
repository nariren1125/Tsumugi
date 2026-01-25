require 'admin/concerns/posts_admin'

ActiveAdmin.register Post do
  include PostsAdmin
end
