# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    if ProgramSetting.active_program.exists?
      active_program = ProgramSetting.active_program.last

      # Get sort parameters
      sort_column = params[:sort_column] || 'total_paid'
      sort_order = params[:sort_order] || 'desc'

      # User Payment Totals Section
      user_totals = Payment.current_program_payments(active_program.program_year)
                          .where(transaction_status: '1') # Only successful payments
                          .joins(:user)
                          .group('users.id', 'users.email')
                          .sum('payments.total_amount::float / 100')

      # Calculate balance due for each user and prepare data for sorting
      user_data_with_balance = user_totals.map do |user_data, total_paid|
        user_id, user_email = user_data
        user = User.find(user_id)
        balance_due = Payment.current_balance_due_for_user(user, active_program.program_year)
        {
          user_id: user_id,
          user_email: user_email,
          user: user,
          total_paid: total_paid,
          balance_due: balance_due
        }
      end

      # Apply sorting
      user_data_with_balance = case sort_column
                               when 'user'
                                 user_data_with_balance.sort_by { |data| data[:user_email] }
                               when 'balance_due'
                                 user_data_with_balance.sort_by { |data| data[:balance_due].to_f }
                               else # 'total_paid' or default
                                 user_data_with_balance.sort_by { |data| data[:total_paid] }
                               end

      # Reverse if descending
      user_data_with_balance.reverse! if sort_order == 'desc'

      div class: 'dashboard_section' do
        h2 "User Payment Totals - Program Year #{active_program.program_year}"

        if user_data_with_balance.any?
          table class: 'index_table' do
            thead do
              tr do
                th do
                  next_order = (sort_column == 'user' && sort_order == 'asc') ? 'desc' : 'asc'
                  a href: admin_dashboard_path(sort_column: 'user', sort_order: next_order), title: 'Click to sort' do
                    text_node 'User '
                    span class: 'sort_indicator' do
                      if sort_column == 'user'
                        text_node sort_order == 'asc' ? '▲' : '▼'
                      else
                        text_node '⇅'
                      end
                    end
                  end
                end
                th 'Total Paid'
                th 'Program Cost'
                th do
                  next_order = (sort_column == 'balance_due' && sort_order == 'asc') ? 'desc' : 'asc'
                  a href: admin_dashboard_path(sort_column: 'balance_due', sort_order: next_order), title: 'Click to sort' do
                    text_node 'Balance Due '
                    span class: 'sort_indicator' do
                      if sort_column == 'balance_due'
                        text_node sort_order == 'asc' ? '▲' : '▼'
                      else
                        text_node '⇅'
                      end
                    end
                  end
                end
                th 'Status'
              end
            end
            tbody do
              user_data_with_balance.each do |data|
                status = data[:balance_due].to_i.zero? ? 'Paid in Full' : 'Outstanding Balance'
                status_class = data[:balance_due].to_i.zero? ? 'paid_full' : 'outstanding'

                tr class: status_class do
                  td data[:user_email]
                  td number_to_currency(data[:total_paid])
                  td number_to_currency(active_program.total_cost)
                  td number_to_currency(data[:balance_due])
                  td status
                end
              end
            end
          end

          div class: 'pagination_info' do
            total_users = user_data_with_balance.count
            paid_in_full = user_data_with_balance.count { |data| data[:balance_due].to_i.zero? }
            text_node "Total Users: #{total_users} | Paid in Full: #{paid_in_full} | Outstanding: #{total_users - paid_in_full}"
          end
        else
          div class: 'blank_slate' do
            text_node 'No successful payments found for the active program.'
          end
        end
      end

      # Hard line separator
      div style: 'width: 100%; height: 4px; background-color: #2d3748; margin: 2rem 0; border: none;' do
        text_node ''
      end

      # Recent Payments Section
      recent_payments = Payment.current_program_payments(active_program.program_year)
                                .includes(:user)
                                .order(created_at: :desc)
                                .limit(20)

      div class: 'dashboard_section' do
        h2 "Recent Payments - Program Year #{active_program.program_year}"

        if recent_payments.any?
          table class: 'index_table' do
            thead do
              tr do
                th 'User'
                th 'Transaction ID'
                th 'Amount'
                th 'Status'
                th 'Account Type'
                th 'Date'
                th 'Actions'
              end
            end
            tbody do
              recent_payments.each do |payment|
                tr do
                  td payment.user.email
                  td payment.transaction_id
                  td number_to_currency(payment.total_amount.to_f / 100)
                  td payment.transaction_status == '1' ? 'Success' : 'Failed'
                  td payment.account_type
                  td payment.created_at.strftime('%Y-%m-%d %H:%M')
                  td do
                    link_to 'View', admin_payment_path(payment), class: 'member_link'
                  end
                end
              end
            end
          end

          div class: 'pagination_info' do
            text_node "Showing #{recent_payments.count} of #{Payment.current_program_payments(active_program.program_year).count} payments"
          end
        else
          div class: 'blank_slate' do
            text_node 'No payments found for the active program.'
          end
        end
      end
    else
      div class: 'blank_slate_container', id: 'dashboard_default_message' do
        span class: 'blank_slate' do
          text_node 'No active program found. Please configure a program setting first.'.html_safe
        end
      end
    end

    # Hard line separator
      div style: 'width: 100%; height: 4px; background-color: #2d3748; margin: 2rem 0; border: none;' do
        text_node ''
      end
    # Static page message
    text_node StaticPage.find_by(location: 'dashboard').message if StaticPage.find_by(location: 'dashboard').present?
  end
end
