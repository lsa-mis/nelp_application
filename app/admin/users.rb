ActiveAdmin.register User do
  menu priority: 3

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :email, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at
  #
  # or
  #
  # permit_params do
  #   permitted = [:email, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  scope :all
  filter :email, as: :select

  # Custom scope for users with zero balance
  scope :zero_balance do |users|
    users.where(id: Payment.users_with_zero_balance.select(:id))
  end

  index do
    selectable_column
    id_column
    column :email
    column 'Balance Due' do |u|
      number_to_currency(u.current_balance_due)
    end
    column :current_sign_in_at
    column :sign_in_count
    column :last_sign_in_at
    column :last_sign_in_ip
    column :created_at
    actions
  end
end
