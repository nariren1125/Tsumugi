require 'admin/concerns/users_admin'

ActiveAdmin.register User do
  include UsersAdmin
end
