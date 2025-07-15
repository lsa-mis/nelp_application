# Rails 7.2.2.1 Upgrade Plan for lsa-mis/nelp_application

## Executive Summary

This document outlines the comprehensive upgrade plan for migrating the `lsa-mis/nelp_application` from **Rails 6.1.7.7** to **Rails 7.2.2.1**. This is a major version upgrade spanning two major versions (6.1 → 7.0 → 7.1 → 7.2) and requires careful planning and execution.

## Current State Analysis

### Application Details
- **Current Rails Version**: 6.1.7.7
- **Target Rails Version**: 7.2.2.1
- **Current Ruby Version**: 3.3.4
- **Application Type**: Rails application with ActiveAdmin, Devise, Webpacker
- **Database**: PostgreSQL
- **Asset Pipeline**: Webpacker 5.0

### Key Dependencies
- ActiveAdmin
- Devise
- Simple Form
- Turbolinks
- Webpacker 5.0
- RSpec Rails (testing)
- Capistrano (deployment)

## Upgrade Strategy

### Recommended Approach: Incremental Upgrades

**IMPORTANT**: Direct upgrade from Rails 6.1 to 7.2 is NOT recommended. We must upgrade incrementally:

1. **Rails 6.1.7.7** → **Rails 7.0.8** (First major upgrade)
2. **Rails 7.0.8** → **Rails 7.1.3** (Minor upgrade) 
3. **Rails 7.1.3** → **Rails 7.2.2.1** (Final minor upgrade)

### Benefits of Incremental Approach
- Easier to identify and fix breaking changes
- Better deprecation warning handling
- Reduced risk of application downtime
- More manageable testing cycles

## Prerequisites & Requirements

### Ruby Version Compatibility
- **Current**: Ruby 3.3.4 ✅ (Compatible)
- **Rails 7.0**: Requires Ruby 2.7.0+ ✅
- **Rails 7.1**: Requires Ruby 2.7.0+ ✅  
- **Rails 7.2**: Requires Ruby 3.1.0+ ✅

### Environment Setup
- **Development**: Working Rails 6.1 application
- **Staging**: Required for testing each upgrade step
- **Production**: Final deployment target
- **CI/CD**: Must be updated to test against new Rails versions

## Phase 1: Pre-Upgrade Preparation

### 1.1 Dependency Audit
- [ ] Audit all gems for Rails 7.x compatibility using [RailsBump](https://railsbump.org)
- [ ] Update or replace incompatible gems
- [ ] Check internal dependencies and engines

**Critical Gems to Review:**
- `activeadmin` - Check Rails 7.2 compatibility
- `devise` - Usually compatible, verify version
- `webpacker` - May need migration to modern JS bundling
- `turbolinks` - Consider migration to Turbo (Rails 7 default)

### 1.2 Test Coverage & Quality
- [ ] Ensure minimum 80% test coverage
- [ ] Fix any failing tests in current Rails version
- [ ] Add tests for critical business logic
- [ ] Run complete test suite to establish baseline

### 1.3 Deprecation Warnings Cleanup
- [ ] Enable deprecation warnings in development/test
- [ ] Fix all Rails 6.1 deprecation warnings
- [ ] Document custom code that may be affected

### 1.4 Code Quality & Technical Debt
- [ ] Review and update any Rails 4/5 legacy patterns
- [ ] Remove unused gems and dependencies
- [ ] Update configuration files to Rails 6.1 standards

## Phase 2: Rails 7.0 Upgrade (Major Breaking Changes)

### 2.1 Critical Changes in Rails 7.0
- **Zeitwerk Autoloading**: Classic autoloader removed, Zeitwerk mandatory
- **Sprockets Optional**: No longer default dependency
- **Spring Upgrade**: Requires Spring 3.0+ 
- **Asset Pipeline Changes**: Webpacker considerations

### 2.2 Breaking Changes to Address

#### Zeitwerk Migration (Critical)
- [ ] Ensure application runs in Zeitwerk mode
- [ ] Fix any autoloading issues
- [ ] Remove manual `require` statements for app code
- [ ] Update file naming conventions if needed

#### Sprockets Dependency
```ruby
# Add to Gemfile if using asset pipeline
gem "sprockets-rails"
```

#### Spring Configuration
- [ ] Update Spring to version 3.0+
- [ ] Update config/spring.rb if exists

#### ActionView Changes
- [ ] `button_to` behavior changed for persisted AR objects
- [ ] Update any custom form helpers

### 2.3 Configuration Updates
- [ ] Run `rails app:update` command
- [ ] Review generated `new_framework_defaults_7_0.rb`
- [ ] Update database.yml for Rails 7 format
- [ ] Configure new security features

### 2.4 Asset Pipeline Considerations
The application currently uses Webpacker 5.0. Options:
1. **Keep Webpacker**: Upgrade to compatible version
2. **Migrate to ImportMaps**: Rails 7 default for simple apps
3. **Migrate to esbuild/webpack**: For complex JS needs

**Recommendation**: Keep Webpacker initially, migrate to modern solution later.

## Phase 3: Rails 7.1 Upgrade (Minor Version)

### 3.1 Notable Changes in Rails 7.1
- Enhanced composite primary key support
- Improved Active Record features
- Better integration with modern JS frameworks

### 3.2 Configuration Updates
- [ ] Update to Rails 7.1 framework defaults
- [ ] Review new configuration options
- [ ] Test application thoroughly

## Phase 4: Rails 7.2 Upgrade (Target Version)

### 4.1 Major Features in Rails 7.2
- **Ruby 3.1+ Required**: ✅ Already compatible
- **Development Containers**: Optional `.devcontainer` support
- **Browser Version Guards**: Optional modern browser enforcement
- **Progressive Web App Files**: Default PWA manifest/service worker
- **RuboCop Omakase Rules**: Default linting configuration
- **GitHub CI Workflow**: Default GitHub Actions setup
- **Brakeman Security**: Default security scanning
- **YJIT Enabled**: Performance improvements (Ruby 3.3+)

### 4.2 Configuration Updates
- [ ] Update to Rails 7.2 framework defaults
- [ ] Configure new security features
- [ ] Optionally enable new features (PWA, browser guards)

## Phase 5: Post-Upgrade Optimization

### 5.1 Performance Improvements
- [ ] Enable YJIT (already on Ruby 3.3.4)
- [ ] Review and optimize database queries
- [ ] Update caching strategies for Rails 7.2

### 5.2 Security Enhancements
- [ ] Configure new security headers
- [ ] Review and update authentication flows
- [ ] Enable new Rails 7.2 security features

### 5.3 Modern Rails Features Adoption
- [ ] Consider Hotwire/Turbo adoption
- [ ] Evaluate modern CSS/JS bundling options
- [ ] Update development workflow tools

## Risk Assessment & Mitigation

### High Risk Areas
1. **Autoloading Changes**: Zeitwerk migration critical
2. **Asset Pipeline**: Webpacker compatibility
3. **Database Migrations**: Large schema changes
4. **Third-party Integrations**: External API compatibility

### Mitigation Strategies
- [ ] Comprehensive staging environment testing
- [ ] Database backup before each upgrade
- [ ] Rollback plan for each phase
- [ ] Feature flags for new functionality
- [ ] Monitoring and alerting setup

## Testing Strategy

### 5.1 Automated Testing
- [ ] Complete test suite execution for each Rails version
- [ ] Integration tests for critical user flows
- [ ] Performance testing with realistic data
- [ ] Security testing with updated framework

### 5.2 Manual Testing
- [ ] Admin interface functionality (ActiveAdmin)
- [ ] User authentication flows (Devise)
- [ ] Form submissions and validation
- [ ] File uploads and processing
- [ ] Email functionality

## Deployment Strategy

### 6.1 Environment Progression
1. **Development**: Local testing and development
2. **Staging**: Full application testing
3. **Production**: Final deployment with monitoring

### 6.2 Rollback Plan
- [ ] Database backup strategy
- [ ] Application version tagging
- [ ] Quick rollback procedures
- [ ] Communication plan

## Timeline Estimation

### Conservative Timeline (Recommended)
- **Phase 1 (Preparation)**: 1-2 weeks
- **Phase 2 (Rails 7.0)**: 2-3 weeks  
- **Phase 3 (Rails 7.1)**: 1 week
- **Phase 4 (Rails 7.2)**: 1 week
- **Phase 5 (Optimization)**: 1-2 weeks

**Total Estimated Duration**: 6-9 weeks

### Aggressive Timeline (Higher Risk)
- **Total Duration**: 3-4 weeks (not recommended for production apps)

## Success Criteria

### Technical Success Metrics
- [ ] All tests passing on Rails 7.2.2.1
- [ ] Application boots successfully
- [ ] All critical features functional
- [ ] Performance maintained or improved
- [ ] Security posture maintained or enhanced

### Business Success Metrics
- [ ] Zero downtime deployment
- [ ] No critical bug reports post-deployment
- [ ] User experience maintained
- [ ] Development velocity maintained

## Resources & References

### Official Documentation
- [Rails 7.2 Release Notes](https://guides.rubyonrails.org/7_2_release_notes.html)
- [Rails 7.1 Release Notes](https://guides.rubyonrails.org/7_1_release_notes.html)
- [Rails 7.0 Release Notes](https://guides.rubyonrails.org/7_0_release_notes.html)
- [Rails Upgrade Guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html)

### Community Resources
- [RailsBump - Gem Compatibility](https://railsbump.org)
- [FastRuby.io Rails Upgrade Guides](https://www.fastruby.io/blog)
- [thoughtbot Rails Upgrade Resources](https://thoughtbot.com/blog)

### Tools & Utilities
- [next_rails gem](https://github.com/fastruby/next_rails) - Dual booting
- [RailsDiff](https://railsdiff.org) - Configuration changes
- [rails app:update](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#the-update-task) - Framework updates

## Next Steps

1. **Review and Approve Plan**: Team review of this upgrade strategy
2. **Environment Setup**: Prepare staging environments
3. **Dependency Audit**: Complete gem compatibility review
4. **Begin Phase 1**: Start with preparation tasks
5. **Establish Timeline**: Finalize timeline based on business needs

---

**Document Status**: Draft v1.0  
**Last Updated**: [Current Date]  
**Prepared For**: lsa-mis/nelp_application Rails Upgrade  
**Contact**: [Your Team/Contact Information]