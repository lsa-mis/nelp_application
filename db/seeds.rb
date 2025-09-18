# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if Rails.env.development?
  AdminUser.create!(email: 'admin@example.com', password: 'password',
                    password_confirmation: 'password')
end

if Rails.env.development?
  ProgramSetting.create!(
    program_year: 2024,
    active: true,
    program_open: Time.zone.now,
    program_close: 2.days.from_now,
    open_instructions: 'Open Instructions',
    close_instructions: 'Close Instructions',
    payment_instructions: 'Payment Instructions'
  )
end

StaticPage.create!([
                     { location: 'about' },
                     { location: 'home' },
                     { location: 'privacy' },
                     { location: 'terms' },
                     { location: 'dashboard' },
                   ])
