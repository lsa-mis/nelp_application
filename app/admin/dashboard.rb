# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    if ProgramSetting.active_program.exists?
      active_program = ProgramSetting.active_program.last

      # Get sort and pagination parameters
      sort_column = params[:sort_column] || 'total_paid'
      sort_order = params[:sort_order] || 'desc'
      page = (params[:page] || 1).to_i
      per_page = 20

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

      # Pagination
      total_users = user_data_with_balance.count
      total_pages = (total_users.to_f / per_page).ceil
      page = [[page, 1].max, total_pages].min if total_pages > 0 # Ensure page is within valid range
      start_index = (page - 1) * per_page
      end_index = start_index + per_page - 1
      paginated_data = user_data_with_balance[start_index..end_index] || []

      div class: 'dashboard_section' do
        h2 "User Payment Totals - Program Year #{active_program.program_year}"

        if user_data_with_balance.any?
          table class: 'index_table' do
            thead do
              tr do
                th do
                  next_order = (sort_column == 'user' && sort_order == 'asc') ? 'desc' : 'asc'
                  a href: admin_dashboard_path(sort_column: 'user', sort_order: next_order, page: page), title: 'Click to sort' do
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
                  a href: admin_dashboard_path(sort_column: 'balance_due', sort_order: next_order, page: page), title: 'Click to sort' do
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
              paginated_data.each do |data|
                status = data[:balance_due].to_i.zero? ? 'Paid in Full' : 'Outstanding Balance'
                status_class = data[:balance_due].to_i.zero? ? 'paid_full' : 'outstanding'

                tr class: status_class do
                  td do
                    link_to data[:user_email], admin_payments_path('q[user_id_eq]' => data[:user_id]),
                            title: "View all payments for #{data[:user_email]}"
                  end
                  td number_to_currency(data[:total_paid])
                  td number_to_currency(active_program.total_cost)
                  td number_to_currency(data[:balance_due])
                  td status
                end
              end
            end
          end

          div class: 'pagination_info' do
            paid_in_full = user_data_with_balance.count { |data| data[:balance_due].to_i.zero? }
            showing_start = total_users.zero? ? 0 : start_index + 1
            showing_end = [end_index + 1, total_users].min
            text_node "Displaying users #{showing_start} - #{showing_end} of #{total_users} | "
            text_node "Paid in Full: #{paid_in_full} | Outstanding: #{total_users - paid_in_full}"
          end

          # Pagination controls
          if total_pages > 1
            div class: 'pagination', style: 'text-align: center; margin: 20px 0;' do
              # Previous button
              if page > 1
                a href: admin_dashboard_path(sort_column: sort_column, sort_order: sort_order, page: page - 1),
                  class: 'pagination_link',
                  style: 'padding: 5px 10px; margin: 0 2px; text-decoration: none;' do
                  text_node '« Previous'
                end
              else
                span style: 'padding: 5px 10px; margin: 0 2px; color: #ccc;' do
                  text_node '« Previous'
                end
              end

              # Page numbers
              (1..total_pages).each do |p|
                if p == page
                  span class: 'current',
                       style: 'padding: 5px 10px; margin: 0 2px; background-color: #5E6469; color: white; border-radius: 3px;' do
                    text_node p.to_s
                  end
                else
                  a href: admin_dashboard_path(sort_column: sort_column, sort_order: sort_order, page: p),
                    class: 'pagination_link',
                    style: 'padding: 5px 10px; margin: 0 2px; text-decoration: none;' do
                    text_node p.to_s
                  end
                end
              end

              # Next button
              if page < total_pages
                a href: admin_dashboard_path(sort_column: sort_column, sort_order: sort_order, page: page + 1),
                  class: 'pagination_link',
                  style: 'padding: 5px 10px; margin: 0 2px; text-decoration: none;' do
                  text_node 'Next »'
                end
              else
                span style: 'padding: 5px 10px; margin: 0 2px; color: #ccc;' do
                  text_node 'Next »'
                end
              end
            end
          end

          # Section separator with subtle styling
          div style: 'width: 100%; height: 1px; background-color: #e2e8f0; margin: 3rem 0 2rem 0; border-radius: 1px; box-shadow: 0 1px 3px rgba(0,0,0,0.08);' do
            text_node ''
          end
        else
          div class: 'blank_slate' do
            text_node 'No successful payments found for the active program.'
          end
        end
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
                  td do
                    link_to payment.user.email, admin_payments_path('q[user_id_eq]' => payment.user_id),
                            title: "View all payments for #{payment.user.email}"
                  end
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
            text_node "Showing most recent #{recent_payments.count} payments"
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

    # Static page message
    text_node StaticPage.find_by(location: 'dashboard').message if StaticPage.find_by(location: 'dashboard').present?
  end
end
