module FamilySettings
  class MembersController < ApplicationController
    before_action :require_login

    def edit
      @family_group = current_family_group
      @members = @family_group ? @family_group.users.includes(:family_group_memberships) : []
    end
  end
end
