ActiveAdmin.register ProgramSetting do
  menu priority: 1

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :program_year, :application_fee, :program_fee, :active, :program_open, :program_close,
                :open_instructions, :close_instructions, :payment_instructions, :allow_payments
  #
  # or
  #
  # permit_params do
  #   permitted = [:program_year, :application_fee, :program_fee, :active, :program_open, :program_close, :open_instructions, :close_instructions, :payment_instructions, :allow_payments]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
