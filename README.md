ruby-lang-mls
=============

The **ruby-lang.org mailing list service/subscriber**.

A Sinatra application that handles mailing list subscriptions
for the www.ruby-lang.org site.

Setup Application
-----------------

1. Clone repository and install dependencies:

   ``` sh
   git clone https://github.com/stomar/ruby-lang-mls.git
   cd ruby-lang-mls
   bundle install
   ```

2. Setup environment variables, e.g. with:

   ``` sh
   export SMTP_USERNAME=john.doe@mymail.org
   export SMTP_PASSWORD=password
   export SMTP_SERVER=smtp.mymail.org
   ```

   If necessary, also set `SMTP_PORT` (default: `587`).

3. Launch:

   ``` sh
   bundle exec rackup config.ru
   ```

4. Open site at `localhost:9292`

Setup Database
--------------

The application can log to a PostgreSQL database, provided the
`DATABASE_URL` environment variable is set and the database is
configured correctly.

- On Heroku, create a PostgreSQL database and make sure `DATABASE_URL`
  points to it.

- For local testing, create a database
  depending on your environment e.g. with:

  ``` sh
  $ sudo -u postgres createdb rlmls
  ```

  Then set `DATABASE_URL` appropriately:

  ``` sh
  $ export DATABASE_URL=postgres://localhost/rlmls
  ```

License
-------

Copyright &copy; 2013 Marcus Stollsteimer

This is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License version 3 or later (GPLv3+),
see [www.gnu.org/licenses/gpl.html](http://www.gnu.org/licenses/gpl.html).
There is NO WARRANTY, to the extent permitted by law.
