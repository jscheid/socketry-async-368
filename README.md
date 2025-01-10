# Test case for `UDPSocket#close` hanging

See https://github.com/socketry/async/issues/368

This is the behaviour I can observe on my machine:

## Running on macOS with Ruby 3.3.0

Running `statsd.timing` only in sync blocks works fine:

```
bundle && bundle exec ruby test.rb 0 # returns after a second or so
```

Running 50/50 sync and async will hang:

```
bundle && bundle exec ruby test.rb 0.5 # hangs
```

So does running with only sync, no async:

```
bundle && bundle exec ruby test.rb 1 # hangs
```

## Running in Docker with Ruby 3.4.1

Running only sync blocks works fine:

```
docker compose run --rm -e ASYNC_PERCENT=0 test # returns after a second or so
```

Unlike running on the host, so does running _only_ async blocks:

```
docker compose run --rm -e ASYNC_PERCENT=1 test # returns after a second or so
```

But, running 50/50 sync and async will hang again:

```
docker compose run --rm -e ASYNC_PERCENT=0.5 test # hangs
```

## Poking around the process

In one terminal:

```
docker compose up test # hangs
```

In another terminal:

```
docker compose exec test bundle exec pry-remote
```

In the pry console:

```ruby
$tasks.each(&:print_hierarchy)
```

... should show one fiber hanging in `IO#close`, the others waiting to get the Mutex.
