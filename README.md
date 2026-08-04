# Effective Work Experience

Interns record their work experience hours and projects, and mentors review them.

## Getting Started

This requires Rails 6+ and Twitter Bootstrap 4 and just works with Devise.

Please first install the [effective_datatables](https://github.com/code-and-effect/effective_datatables) gem.

Please download and install the [Twitter Bootstrap4](http://getbootstrap.com)

Add to your Gemfile:

```ruby
gem 'effective_work_experience'
```

Run the bundle command to install it:

```console
bundle install
```

Then run the generator:

```ruby
rails generate effective_work_experience:install
```

The generator will install an initializer which describes all configuration options and creates a database migration.

Then migrate the database:

```ruby
rake db:migrate
```

## Configuration

All configuration options are documented in the `config/initializers/effective_work_experience.rb` initializer.

## Authorization

All authorization checks are handled via the effective_resources gem found in the `config/initializers/effective_resources.rb` file.

## Permissions

The permissions you actually want to define are as follows (using CanCan):

```ruby
if user.persisted?
end

if user.admin?
  can :admin, :effective_work_experience
end
```

## License

MIT License. Copyright [Code and Effect Inc.](http://www.codeandeffect.com/)

## Testing

Run tests by:

```ruby
rails test
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Bonus points for test coverage
6. Create new Pull Request
