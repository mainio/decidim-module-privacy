# Decidim::Privacy

In the regular decidim system, participants' accounts information such as their names, emails, nicknames, etc. and their activities, such as comments, votes, and more, are considered public. This means that anyone can search for users' profile information and their activities. However, this openness has recently raised concerns among some participants (see [here](https://www.hel.fi/en/news/personal-data-breach-at-omastadihelfi-corrective-measures-have-been-taken) for more information).

To address these concerns, this module provides an additional layer of privacy to user accounts. By installing this module, users now have the option to switch their accounts to private. Furthermore, all information related to private users will be hidden from third parties, including Decidim API.

## Usage

After installing this module, "Privacy settings" section will be added to the participant account settings as shown in the below image. Users will be able to make their profile public/ private. By default, accounts are private.
![Privacy settings added to the participant's account settings](docs/privacy_settings.png)

Later on, if a private user wants to participate in an activity which needs a public profile (such as leaving a comment, creating a profile, etc), user's permission will be asked prior to performing the action via a popup consent, as shown in below image.
![Popup opened for a private user wanting to create a new proposal](docs/public_profile_popup.png)


## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-privacy"
```

And then execute:

```bash
bundle
bundle exec rails decidim_privacy:install:migrations
bundle exec rails db:migrate
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
