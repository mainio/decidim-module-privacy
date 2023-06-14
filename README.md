# Decidim::Privacy

Enable privacy configuration to Decidim.

## Usage

Privacy will be available as a Module for a Participatory
Space.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-privacy"
```

And then execute:

```bash
bundle
```

## Console queries

This module includes changes made to the default scope
of Decidim, which also affects the console environment.

For example the User model has been scoped to only find
public users by default (Users that have a value in the attribute
published_at: *Timestamp*). To list users that are private (published_at: nil)
and public, add "unscoped" -method to the query

*Example:*

```bash
Decidim::User.unscoped.all
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
