require 'admin/concerns/invite_tokens_admin'

ActiveAdmin.register InviteToken do
  include InviteTokensAdmin
end
