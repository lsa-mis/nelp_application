ActiveAdmin.register Payment do
  menu priority: 2

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :transaction_type, :transaction_status, :transaction_id, :total_amount, :transaction_date,
                :account_type, :result_code, :result_message, :user_account, :payer_identity, :timestamp, :transaction_hash, :user_id, :program_year
  #
  # or
  #
  # permit_params do
  #   permitted = [:transaction_type, :transaction_status, :transaction_id, :total_amount, :transaction_date, :account_type, :result_code, :result_message, :user_account, :payer_identity, :timestamp, :transaction_hash, :user_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  actions :index, :show, :new, :create, :update, :edit

  controller do
    def scoped_collection
      super.includes(:user)
    end
  end

  filter :user_id, as: :select, collection: -> { User.order(:email).map { |u| [u.email, u.id] } }
  filter :program_year, as: :select
  filter :account_type, as: :select
  filter :created_at

  form do |f| # This is a formtastic form builder
    f.semantic_errors # shows errors on :base
    f.inputs do
      f.input :user_id, as: :select, collection: User.all
      f.input :total_amount
      li "Transaction Type #{f.object.transaction_type}" unless f.object.new_record?
      f.input :transaction_type, input_html: { value: '1' } unless f.object.persisted?
      li "Transaction Status #{f.object.transaction_status}" unless f.object.new_record?
      f.input :transaction_status, input_html: { value: '1' } unless f.object.persisted?
      f.input :transaction_id
      f.input :account_type
      f.input :result_message
      f.input :transaction_date, input_html: { value: DateTime.now.strftime('%Y%m%d%H%M').to_s }
      li "Camp Year #{f.object.program_year}" unless f.object.new_record?
      unless f.object.persisted?
        f.input :program_year,
                input_html: { value: current_program&.program_year || Date.current.year }
      end
    end
    f.actions         # adds the 'Submit' and 'Cancel' button
  end

  index do
    column :user, sortable: 'users.email'
    column 'Type', &:transaction_type
    column 'Status', &:transaction_status
    column :transaction_id
    column 'Total Amount' do |p|
      number_to_currency(p.total_amount.to_f / 100)
    end
    column :transaction_date
    column :account_type
    column :result_code
    column :result_message
    column :user_account
    column :payer_identity
    column :timestamp
    column :program_year
    actions
  end
end
