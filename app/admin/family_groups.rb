require 'admin/concerns/family_groups_admin'

ActiveAdmin.register FamilyGroup do
  include FamilyGroupsAdmin
end
