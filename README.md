# PGHTTP

Don't use this. Please, please, don't. It's a terrible idea.

## What is it?

- A small typescript app that forwards incoming http requests to a postgres database.
- A postgres schema that contains the main handle function and a few helpers.
- A file with example routes.

## Why?

I remembered back when I worked at OmniTI, I was talking with a coworker who was very
knowledgeable about postgres. He mentioned that even though postgres is a wonderful
piece of tech, the database server is still the hardest part of the stack to scale,
so it's best to keep as much processing out of the database, while still making sure
to use the database for what it's good at.

This is the opposite of that.

# I found a bug! I have a question! It doesn't work!

I'm not surprised. This is a terrible idea. If you want to fix it, go ahead. If you
want to ask me a question, go ahead. If you want to tell me it doesn't work, I know.
I'm not surprised. This is a terrible idea.

# How do I use it?

Don't.

# No, really, how do I use it?

You don't.

# I'm going to use it.

Fine. You'll need to create a postgres database, and run the schema.sql file against
it. Then you'll need to create a .env file with the following variables:

```
PGHOST=
PGPORT=
PGDATABASE=
PGUSER=
PGPASSWORD=
PORT=
```

Then you'll need to run `pnpm install` and `pnpm run start`. Then you'll need
to send http requests to the server. Then you'll need to realize that this is
a terrible idea. Then you'll need to stop using it. Then you'll need to go
outside and get some fresh air.

# License

MIT
