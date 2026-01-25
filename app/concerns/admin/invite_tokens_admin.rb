module Admin
  module InviteTokensAdmin
    def self.included(dsl)
      dsl.instance_eval do
        index do
          selectable_column
          id_column
          column :token
          column('FamilyGroup') { |token| token.family_group&.name }
          column :expires_at
          column('Status') do |token|
            token.expires_at.present? && token.expires_at > Time.current ? 'Valid' : 'Expired'
          end
          actions
        end

        show do
          attributes_table do
            row :id
            row :token
            row('FamilyGroup') { |token| token.family_group&.name }
            row :expires_at
            row('Status') { |token| token.expires_at.present? && token.expires_at > Time.current ? 'Valid' : 'Expired' }
            row :created_at
            row :updated_at
          end
        end
      end
    end
  end
end
