ActiveAdmin.register StaticPage do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters

  permit_params :location, :message

  actions :all, except: [:destroy, :show, :new]

  index title: 'Manage messages on static pages'do
    column :location
    actions
  end

  form do |f|
    f.inputs do
      f.input :location
      f.input :message, as: :action_text
    end
    f.actions
  end

end