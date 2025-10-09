# frozen_string_literal: true

namespace :sample_data do
  desc "Generate sample payment records for testing"
  task generate_payments: :environment do
    unless Rails.env.development?
      puts "This task can only be run in development environment"
      exit
    end

    puts "Generating sample payment data..."

    # Get or create a program setting
    program = ProgramSetting.find_or_create_by!(program_year: 2024) do |p|
      p.active = true
      p.program_open = Time.zone.now
      p.program_close = 2.days.from_now
      p.application_fee = 5000 # $50.00
      p.program_fee = 25000    # $250.00
      p.allow_payments = true
      p.open_instructions = 'Open Instructions'
      p.close_instructions = 'Close Instructions'
      p.payment_instructions = 'Payment Instructions'
    end

    # Sample last names for more realistic data
    last_names = %w[
      Smith Johnson Williams Brown Jones Garcia Miller Davis Rodriguez Martinez
      Hernandez Lopez Gonzalez Wilson Anderson Thomas Taylor Moore Jackson Martin
      Lee Perez Thompson White Harris Sanchez Clark Ramirez Lewis Robinson Walker
      Young Allen King Wright Scott Torres Nguyen Hill Flores Green Adams Nelson
      Baker Hall Rivera Campbell Mitchell Carter Roberts Gomez Phillips Evans Turner
      Diaz Parker Cruz Edwards Collins Reyes Stewart Morris Morales Murphy Cook
      Rogers Gutierrez Ortiz Morgan Cooper Peterson Bailey Reed Kelly Howard Ramos
      Kim Cox Ward Richardson Watson Brooks Chavez Wood James Bennett Gray Mendoza
      Ruiz Hughes Price Alvarez Castillo Sanders Patel Myers Long Ross Foster Jimenez
    ]

    first_names = %w[
      James Mary Michael Patricia Robert Jennifer John Linda William Elizabeth
      David Barbara Richard Susan Joseph Jessica Thomas Sarah Charles Karen
      Christopher Nancy Daniel Lisa Matthew Betty Donald Ashley Mark Kimberly
      Paul Emily Donald Donna George Carol Kenneth Michelle Steven Laura
      Edward Sandra Brian Dorothy Ronald Ashley Anthony Melissa Kevin Amanda
      Jason Stephanie Jeff Rebecca Ryan Deborah Gary Sharon Nicholas Laura
      Jacob Cynthia Tyler Amy Scott Angela Eric Kathleen Stephen Shirley
      Jonathan Emma Brandon Donna William Ruth Frank Anna Raymond Diana
    ]

    transaction_statuses = ['1', '2', '3'] # 1=success, 2=pending, 3=failed
    account_types = %w[VISA MASTERCARD AMEX DISCOVER]

    # Keep track of created users to avoid duplicates
    created_count = 0
    target_count = 100

    puts "Creating users and payments..."

    target_count.times do |i|
      # Generate unique email
      first_name = first_names.sample
      last_name = last_names.sample
      email = "#{first_name.downcase}.#{last_name.downcase}.#{i}@example.com"

      # Create user
      user = User.create!(
        email: email,
        password: 'password123',
        password_confirmation: 'password123'
      )

      # Generate 1-3 payments per user to make it more realistic
      payment_count = rand(1..3)

      payment_count.times do |payment_num|
        status = transaction_statuses.sample
        amount = case payment_num
                 when 0
                   program.application_fee # First payment is application fee
                 when 1
                   program.program_fee # Second payment is program fee
                 else
                   rand(5000..30000) # Additional payments vary
                 end

        Payment.create!(
          user: user,
          transaction_type: '1',
          transaction_status: status,
          transaction_id: "TXN#{Time.current.to_i}#{rand(1000..9999)}",
          total_amount: amount.to_s,
          transaction_date: rand(30.days.ago..Time.current).strftime('%Y%m%d%H%M'),
          account_type: account_types.sample,
          result_code: status == '1' ? '00' : rand(100..999).to_s,
          result_message: status == '1' ? 'Success' : 'Processing',
          user_account: "**** **** **** #{rand(1000..9999)}",
          payer_identity: email,
          timestamp: rand(30.days.ago..Time.current).to_i.to_s,
          transaction_hash: Digest::SHA256.hexdigest("#{email}#{Time.current.to_i}#{rand}"),
          program_year: 2024
        )

        created_count += 1
      end

      print "\rCreated #{i + 1}/#{target_count} users with #{created_count} payments..."
    end

    puts "\n"
    puts "✓ Successfully created #{target_count} users"
    puts "✓ Successfully created #{created_count} payments"
    puts "✓ All records are associated with program year 2024"
    puts "\nYou can now view them in ActiveAdmin at /admin/payments"
  end

  desc "Clean up sample payment data"
  task cleanup_payments: :environment do
    unless Rails.env.development?
      puts "This task can only be run in development environment"
      exit
    end

    print "Are you sure you want to delete all payments and users from example.com? (yes/no): "
    confirmation = STDIN.gets.chomp

    if confirmation.downcase == 'yes'
      users = User.where("email LIKE ?", "%@example.com")
      payment_count = Payment.where(user: users).count
      user_count = users.count

      Payment.where(user: users).destroy_all
      users.destroy_all

      puts "✓ Deleted #{payment_count} payments"
      puts "✓ Deleted #{user_count} users"
    else
      puts "Cleanup cancelled"
    end
  end
end
