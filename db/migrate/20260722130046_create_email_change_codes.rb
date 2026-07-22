class CreateEmailChangeCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :email_change_codes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :new_email, null: false
      t.string :code, null: false
      t.datetime :used_at

      t.datetime :created_at, null: false
    end

    add_index :email_change_codes, %i[user_id created_at]
  end
end
