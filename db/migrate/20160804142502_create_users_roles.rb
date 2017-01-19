class CreateUsersRoles < ActiveRecord::Migration
  def change
    create_table :roles_users do |t|
      t.integer :user_id, null: false
      t.integer :role_id, null: false
      t.timestamps null: false
    end
    add_index :roles_users, [:user_id, :role_id],     :unique => true

    Role.create_standard_roles
  end
end
