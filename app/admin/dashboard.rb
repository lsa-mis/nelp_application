# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        text_node "Select a menu item to manage system".html_safe
      end
    end
    text_node StaticPage.find_by(location: 'dashboard').message if StaticPage.find_by(location: 'dashboard').present?
  end # content
end
