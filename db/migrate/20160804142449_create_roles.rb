class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.timestamps null: false
    end
    add_index :roles, :code,     :unique => true
    
    Role.super_user_role
    Role.account_admin_user_role
  end
end
