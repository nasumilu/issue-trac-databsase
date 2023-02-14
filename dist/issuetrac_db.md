# IssueTracDB CLI

```shell
$ ./issuetrac_db --help
Name issuetrac_db

Version 1.0.0

Description
   A simple bash script used to setup the IssueTrac database(s). For more information go to the project
   repository at https://github.com/nasumilu/issue-trac.

Usage
  issuetrac_db [PLATFORM] [COMMAND] [OPTIONS ...]
  issuetrac_db [PLATFORM] setup [DATABASE] [OPTIONS ...]


Platforms
  mysql                Using setup script ./mysql/mysql.sh
  postgresql           Using setup script ./postgresql/postgresql.sh


Commands
  setup                Setup the database(s)
  list                 List the database(s) supported a [PLATFORM]


Options
  -H, --host=name     Connect to host (default: localhost)
  -p, --port=#        Port number to use for connection (default: to the specified platform default)
  -u, --user=name     User for login
  -P, --password=[password]
                      Password to use when connecting to the server. Prompted if not provided
  -t, --tiger-year=#  The Tiger/Line Shapefiles dataset year. (default: 2022)
  -v, --verbose       Show more output and progress
  -h, --help          This message
```