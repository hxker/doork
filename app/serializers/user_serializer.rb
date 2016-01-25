class UserSerializer < ActiveModel::Serializer
  attributes :id, :email

  # def email
  #   if owner? || object.email_public == true
  #     object.email
  #   else
  #     ''
  #   end
  # end
end
