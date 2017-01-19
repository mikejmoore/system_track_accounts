class SshKeys < ActiveRecord::Migration
  def change
    create_table :ssh_keys do |t|
      t.integer :user_id, null: false
      t.text :public_key, null: false
      t.string :public_key_hash, null: false  #, :binary, :limit => 400.byte
      t.string :code, null: false
      t.timestamps null: false
    end
    add_index :ssh_keys, [:user_id],  :unique => false
    add_index :ssh_keys, [:public_key_hash], :unique => true #,  length: 200
  end
end
