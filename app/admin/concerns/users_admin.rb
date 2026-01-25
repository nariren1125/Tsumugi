module UsersAdmin
  def self.included(dsl)
    dsl.instance_eval do
      actions :index, :show, :edit, :update

      permit_params(*(%i[name email line_uid family_group_id role] & User.column_names.map(&:to_sym)))

      controller do
        def scoped_collection
          super.includes(:family_group, :family_groups)
        end
      end

      index do
        selectable_column
        id_column
        column(:name)    if User.column_names.include?('name')
        column(:email)   if User.column_names.include?('email')
        column(:line_uid) if User.column_names.include?('line_uid')

        # 旧 users.family_group_id を “名前” で見せる
        column('Legacy FamilyGroup') { |user| user.family_group&.name }

        # 現行 memberships の数
        column('Groups') { |user| user.family_groups.size }

        column :created_at
        actions
      end

      filter :id
      filter(:name)    if User.column_names.include?('name')
      filter(:email)   if User.column_names.include?('email')
      filter(:line_uid) if User.column_names.include?('line_uid')
      filter :family_group, label: 'Legacy FamilyGroup'
      filter :created_at
      filter :updated_at

      show do
        attributes_table do
          row :id
          row(:name)    if User.column_names.include?('name')
          row(:email)   if User.column_names.include?('email')
          row(:line_uid) if User.column_names.include?('line_uid')

          row('Legacy FamilyGroup') { |user| user.family_group&.name }
          row('FamilyGroups (current memberships)') { |user| user.family_groups.map(&:name).join(', ') }

          row :created_at
          row :updated_at
        end
      end

      form do |f|
        f.inputs do
          f.input :name    if User.column_names.include?('name')
          f.input :email   if User.column_names.include?('email')
          f.input :line_uid if User.column_names.include?('line_uid')
          f.input :family_group_id if User.column_names.include?('family_group_id')
          f.input :role if User.column_names.include?('role')
        end
        f.actions
      end
    end
  end
end
