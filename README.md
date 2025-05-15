
# Building A Simple PL/pgSQL Postgres extension

Postgres has the ability to be extended.  This is a fantastic capability.
Even a simple extension in PL/pgSQL has some advantages.   As an extension it provides a nice way to package ability 
set of functions together into a single bundle.   A PL/pgSQL extension is also the simplest form of a 
Postgres extension.   Let's start wit this as an example.

There are 3 files that you must have to build this extension.   Two extra files will make it 
much easier to install and test the extension.

1. The *control* file.  This specifies what the extension is and how Postgres will load it.
2. The *extension.sql* file.   This file will have the `.sql` code in it for the extnsion.
3. The *Makefile* file. This tells how to install the file.
4. A *setup.sql* file that installs the extension in a schema.
5. A *test.sql* file that tests the extension to verify that it works.


You will also need a copy of Postgres installed locally on your system to build and test an extension.


## The *Control* file.

The file must be named `<extension>.control`.   In this case the file is `pg_make_title.control`. It is only a 4 lines.

```sql
comment = 'Convert Text to Title Format'
default_version = '1.0'
module_pathname = '$libdir/pg_make_title'
relocatable = true
```
The `comment` is a text description of what the extension will do.

The `default_version` ( Note the quote marks ) specifies the most curent version to load.

The `module_pathname` specifies where the file will be loaded from to install it into Postgres.

The `relocatable` tells postgres the kind of an extension this is.   For now just set it to `true`.


## The *extension.sql* file.

The file must be named based on the extension and the version number.  In this case, 
the file is `pg_make_title--1.0.sql`. 

```sql
-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION pg_make_title" to load this file. \quit

-- convet_to_title will take a string and convert the initial charactes of each word to a capital letter.
CREATE FUNCTION IF NOT EXISTS convert_to_title(s text) RETURNS text
LANGUAGE plpgsql IMMUTABLE STRICT 
AS $$
DECLARE
	rv text;
BEGIN
	rv := (SELECT INITCAP(s));
	RETURN(rv);
END;
$$;
```


## The *Makefile* file.

The makefile has 3 lines at the top that specify our extension.   Before we start with on the file there are 
some things we should check.

I am working on a Mac with Postgres installed via the Postgres App.  If you have postgres installed with `brew` the path will be different.
There are 3 things that should be validated.   First that you have GNU `make` intalled.   With `brew` you can install make  with 

```bash
$ brew install make
...
$ make --version
GNU Make 4.4.1
Built for aarch64-apple-darwin24.0.0
Copyright (C) 1988-2023 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```

Now check that you have the configuration for Postgres setup correctly.  The executables for postgres should be in your PATH.
Validate that you can run pg_config.   

```bash
$ pg_config --version
PostgreSQL 17.2 (Postgres.app)
```

The makefile has 3 lines that you will need to set.   The first is a description of the extension.
The `EXTENSION` and `DATA` are based on the name of the extension and the version number.   The
version number must match the version in the `default_version` in the control file.

```Makefile
PGFILEDESC = "Extension to convert a string of words to title by capaitilizing the first letter of each word"
EXTENSION = pg_make_title
DATA = pg_make_title--1.0.sql

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
```


Now install the extension into the Postgres directory.   Depending on your installation of Postgres this
step may fail due to permissions on the extension directory.   With the Mac APP version of Postgres you
are an owner of the directory ant this will work.   On a Linux install you may need to become the `postgres` account for this to work.

```bash 
$ make install
```



Once the extension is installed in the Postgres direcotry you can install the extension in your Postres login account.
Save this in the `setup.sql` file.


$ psql
pschlump=# CREATE EXTENSION IF NOT EXISTS pg_make_title;
pschlump=# \q


And then run a simple test.

```bash
$ psql
pschlump=# SELECT convert_to_title('a title for something');
   convert_to_title
-----------------------
 A Title For Something
(1 row)

pschlump=# \q
```

A more comprehensive test, in the file `test1.sql`:


```sql


-- A tests that results in 'PASS'/'FAIL' 

DO $$
DECLARE
 	l_txt text;
 	n_err int;
	l_msg text;
BEGIN

 	n_err = 0;

	SELECT convert_to_title('12345')
		into l_txt;
	if l_txt != '12345' then
		RAISE NOTICE 'Failed to convert 12345 to 12345';
		n_err = n_err + 1;
	end if;

	SELECT convert_to_title('A Title')
		into l_txt;
	if l_txt != 'A Title' then
		RAISE NOTICE 'Failed to convert "A Title" to "A Title"';
		n_err = n_err + 1;
	end if;

	SELECT convert_to_title('a title')
		into l_txt;
	if l_txt != 'A Title' then
		RAISE NOTICE 'Failed to convert "a title" to "A Title"';
		n_err = n_err + 1;
	end if;


	if n_err = 0 then
		RAISE NOTICE 'PASS';
	else 
		RAISE NOTICE 'FAIL';
	end if;

END;
$$ LANGUAGE plpgsql;

```


And run the test:


```bash
pschlump=# \i test1.sql
psql:a.sql:42: NOTICE:  PASS
DO
philip=# \q
```

## github.com code

All of the coe for this is available on github.com at (https://github.com/pschlump/pgextension01)[https://github.com/pschlump/pgextension01]

