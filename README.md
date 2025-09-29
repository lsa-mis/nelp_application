# NELP Application

A Rails-based payment management system for the NELP (New England Literature Program) application process. This application handles user registration, payment processing, and administrative management for program fees and application costs.
[More info...](https://lsa.umich.edu/nelp)

## 🚀 Features

### User Features

- **User Registration & Authentication** - Secure user accounts with Devise
- **Payment Processing** - Integrated payment system with Nelnet payment gateway
- **Payment History** - View all payment transactions and receipts
- **Balance Tracking** - Real-time balance calculations for program fees
- **Static Content** - Access to program information, privacy policy, and terms

### Administrative Features

- **ActiveAdmin Interface** - Comprehensive admin dashboard
- **User Management** - View and manage user accounts
- **Payment Administration** - Monitor and manage all payments
- **Program Settings** - Configure program years, fees, and schedules
- **Content Management** - Manage static pages and program instructions

## 🛠 Technology Stack

- **Ruby**: 3.4.4
- **Rails**: 7.2.2.1
- **Database**: PostgreSQL
- **Authentication**: Devise
- **Admin Interface**: ActiveAdmin
- **Payment Gateway**: Nelnet
- **Asset Pipeline**: dartsass-rails (SCSS compilation)
- **Frontend**: Stimulus, Turbo, Importmap
- **Testing**: RSpec, FactoryBot, Capybara

## 📋 Prerequisites

- Ruby 3.4.4
- PostgreSQL
- Node.js (for asset compilation)
- Git

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/lsa-mis/nelp_application
cd nelp_application
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Database Setup

```bash
# Create and setup the database
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

### 4. Environment Configuration

Copy the example environment files and configure your credentials:

```bash
# Configure your database credentials in config/database.yml
# Set up your Nelnet payment gateway credentials in Rails credentials
```

### 5. Start the Application

```bash
# Start the Rails server
bin/rails server

# Or use the development script
bin/dev
```

The application will be available at `http://localhost:3000`

## 🔧 Configuration

### Payment Gateway Setup

Configure your Nelnet payment gateway credentials in Rails credentials:

```ruby
# config/credentials.yml.enc
NELNET_SERVICE:
  DEVELOPMENT_KEY: your_dev_key
  DEVELOPMENT_URL: your_dev_url
  PRODUCTION_KEY: your_prod_key
  PRODUCTION_URL: your_prod_url
  ORDERTYPE: your_order_type
  SERVICE_SELECTOR: QA # or PROD
```

### Admin Access

Create an admin user in the Rails console:

> the seed file will create the admin user

## 🧪 Testing

The application uses RSpec for testing. Run the test suite:

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/models/
bundle exec rspec spec/controllers/
bundle exec rspec spec/features/
```

### Test Coverage

- Model validations and associations
- Controller actions and authorization
- Payment processing workflows
- User authentication flows
- Admin functionality

## 📁 Project Structure

```
app/
├── admin/                 # ActiveAdmin configurations
├── controllers/           # Application controllers
├── models/               # ActiveRecord models
├── views/                # ERB templates
├── assets/               # SCSS stylesheets and images
└── javascript/           # Stimulus controllers

config/
├── initializers/         # Application configuration
├── locales/             # Internationalization files
└── routes.rb            # Application routes

spec/                    # Test files
├── models/              # Model tests
├── controllers/         # Controller tests
├── features/            # Integration tests
└── factories/           # FactoryBot factories
```

### Environment-Specific Configuration

- **Development**: Uses test payment gateway
- **Staging**: Uses test payment gateway with production-like setup
- **Production**: Uses live payment gateway

## 📊 Key Models

### User

- Handles authentication and user management
- Tracks payment history and balances
- Manages user sessions and preferences

### Payment

- Stores payment transaction details
- Calculates balances and payment status
- Integrates with Nelnet payment gateway

### ProgramSetting

- Manages program years and fee structures
- Controls program availability windows
- Stores program-specific instructions

### AdminUser

- Provides administrative access
- Manages application settings and content

## 🔐 Security Features

- **Authentication**: Secure user login with Devise
- **Authorization**: Role-based access control
- **Payment Security**: Secure hash generation for payment processing
- **Data Protection**: Encrypted credentials and sensitive data
- **CSRF Protection**: Built-in Rails CSRF protection

## 🐛 Troubleshooting

### Common Issues

1. **Payment Gateway Errors**
   - Verify Nelnet credentials are correctly configured
   - Check that the service selector matches your environment

2. **Database Connection Issues**
   - Ensure PostgreSQL is running
   - Verify database credentials in `config/database.yml`

3. **Asset Compilation Issues**
   - Run `bin/rails assets:precompile` for production
   - Check that dartsass-rails is properly configured

### Getting Help

- Check the application logs in `log/` directory
- Review the test suite for expected behavior
- Consult Rails and gem documentation

## 📝 License

[MIT License](LICENSE)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📞 Support

For technical support or questions about the NELP application, please contact the development team.
