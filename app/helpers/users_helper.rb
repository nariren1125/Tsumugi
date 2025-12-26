def role_badge_class(role)
  case role.to_sym
  when :father
    'bg-blue-100 text-blue-700'
  when :mother
    'bg-pink-100 text-pink-700'
  else
    'bg-gray-100 text-gray-700'
  end
end
