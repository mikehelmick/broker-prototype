# Broker Prototype

Prototype of the Broker and Trigger model. This is aimed at validating the user
model around utilizing the broker and trigger objects to send, subscribe to,
receive, and reply to CloudEvent messages.

There are two projects in this repository:

## broker

A Phoenix framework based API UI and JSON API for interacting with the broker.

The broker is implemented as an in-memory system only, registered event types,
triggers, delivery statistics, and the events ledger are not persisted between
runs.

## eventclient

A simple client that has a script for registering some event types and
kicking things off.

# Running it all

## Starting the Broker Server

 * Install [Elixir](https://elixir-lang.org/install.html)
 * Install [Pheonix](https://hexdocs.pm/phoenix/installation.html)
 * Start the broker server
   * `cd broker`
   * `mix deps.get`
   * `mix deps.compile`
   * `mix phx.server`
 * You can access the UI for the server at [localhost:4000](http://localhost:4000/)

## Running the client

 * `cd eventclient`
 * Start interactive elixir, `iex -S mix`
 * Now you can run commands from the event client. Here is the most basic example
   * `Demo.setup_demo()`
     * This registered 2 event types and 4 triggers, you can see them in your browser at the URL above
   * `Demo.send_login_event("1", "Stephanie", "this.is.pii@example.com", "31", "Seattle")`
     * You can see the output in the console for the broker Server
     * You can see some of the event details in the UI as well
 * If you want to manipulate the API directly, see the `EventClient` module
