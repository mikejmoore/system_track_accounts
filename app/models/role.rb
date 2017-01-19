
class Role < ActiveRecord::Base
  include RoleLogic
  
  has_and_belongs_to_many :users
  
  def self.super_user_role
    return Role.find_by_code(SUPER_USER_CODE)
  end
  
  def self.account_admin_user_role
    return Role.find_by_code(ACCOUNT_ADMIN_CODE)
  end
  
  def self.staff_role
    return Role.find_by_code(STAFF_ROLE_CODE)
  end
  
  def self.create_standard_roles
    Role.create_role_if_not_exist(Role::SUPER_USER_CODE, "Super User")
    Role.create_role_if_not_exist(Role::ACCOUNT_ADMIN_CODE, "Account Administrator")
    Role.create_role_if_not_exist(Role::STAFF_ROLE_CODE, "Staff")
  end
  
  def self.create_role_if_not_exist(code, name)
    role = Role.find_by_code(code)
    if (!role)
      role = Role.new
      role.code = code
      role.name = name
      role.save!
    end
  end
end
