# Session Types without Tiers: Implementation

## Introduction

This is the artifact for Session Types without Tiers: namely, the modifications
to the Links programming language to support exception handling and cross-tier
session-typed communication.

The artifact consists of a Docker image, along with scripts to install and
interact with the image.

We provide several example Links programs:

  * the cancellation examples in Section 2.1 of the paper
    (examples/paper-exampels)
  * examples of incorrect implementations of the 2FA server caught by session types in Links
    (examples/caught-errors)
  * examples of distributed exception handling
    (examples/distributed-exceptions)
  * the chat server example
    (examples/chatserver)
  * a web-based version of the two factor authentication example
    (examples/two-factor)

## Structure

  * `links-docker` contains the files used for the Docker image
  * `links` contains the source code of the Links language
  * `custom-examples` is a folder shared between the host and container, useful
     if you wish to try your own examples
  * `prepare.sh` is a script to prepare the Docker image
  * `cleanup.sh` is a script to remove the image and containers after evaluation
  * `run-chatserver.sh` launches the chat server example
  * `run-two-factor.sh` launches the 2FA example
  * `run-example.sh` is a interactive script to run individual examples
  * `run-interactive.sh` launches the Links REPL
  * `run-custom.sh` runs a custom example file
  * `run-shell.sh` runs a bash shell for the container
  * `run-unit-tests.sh` runs the session exceptions unit tests

## Sample evaluation workflow

  1. Ensure you have `docker` installed. On Ubuntu, run `sudo apt-get install
     docker`.
  2. Ensure you have added yourself to the `docker` group: `sudo usermod -a -G
     docker <username>`
  3. Run `./prepare.sh` to install the image and prepare the docker container
     (and you might wish to grab a coffee while this churns through)
  4. Run the chatserver example by invoking `./run-chatserver.sh` and follow the
     instructions in the "Chatserver" section later in this guide
  5. Run the 2FA example by invoking `./run-two-factor.sh` and follow the
     instructions in the "Two-factor authentication example" section later in
     this guide
  6. Run the smaller examples by invoking `./run-example.sh`. Note that
     the "Distributed Exceptions" examples require navigating to
     `http://localhost:8080` in your browser.
  7. Run the unit tests by invoking `./run-unit-tests.sh`. If you wish
     to look at the unit tests, you can get to them via the `unit-tests`
     symlink.
  8. Remove any leftover containers and the image by running
     `./cleanup.sh`

You can also run your own examples by adding the file to the `custom_examples`
directory and running `./run_custom.sh <example file name>`.
For example, try running `./run_custom.sh helloworld.links`.

## Installing Links
We strongly recommend using the Docker image. If you do not wish to use Docker
however, you can install Links from source on an Ubuntu 16.04 install as
follows:

  1. Install the system dependencies using `sudo apt install opam m4 libssl-dev pkg-config`
  2. Run `opam init`
  3. Run `opam switch 4.06.0`
  4. Run ``` eval `opam config env` ``` (backticks around 'opam config env')
  5. Run `opam install dune`
  6. Run `opam pin add links .` to install Links and its dependencies
  7. Use links by invoking `linx`

## Relevant source files

The source can be found in the `links` directory. Relevant source files
you might wish to look at:

  * `links/core/desugarSessionExceptions.ml` -- desugaring of
    try-as-in-otherwise into handlers (sec. 5.4)
  * `links/core/websocketMessages.ml` -- messages sent from client to be
    processed by server
  * `links/core/channelVarUtils.ml` -- traversal of values to find endpoint IDs,
    required for cancellation of names containd in values and contexts
  * `links/core/proc.ml` -- server concurrency runtime
  * `links/lib/js/jslib.js` -- client concurrency runtime
  * `links/core/evalir.ml` -- server interpreter

## Running the examples

### Smaller examples

Running ./run-example.sh will provide you with an interactive script
allowing you to launch each of the smaller examples. Alternatively, you can run
./run-example.sh with an argument to launch an example by path.

### Chatserver

To run the chat server example, run
  ```
    ./run_chatserver.sh
  ```

Next, visit `http://localhost:8080` in your browser. Sign in with a user name.
Open another browser window, and visit the same page. Sign in with a different
user name. You should be able to chat. Finally, close one of the browser
windows. You should see that a message is displayed showing that the other
participant has disconnected (meaning that the act of closing a browser
resulted in an exception in the server, which broadcasted a "leave"
message).

### Two-factor authentication example

To run the two-factor authentication example, run

  ```
    ./run_two_factor.sh
  ```

Again, navigate to `http://localhost:8080`.

The correct credentials are `User` and `hunter2`.
You will then be prompted for a key -- the "algorithm" for calculating the
response is just to add one to the challenge key you are presented.

You can make the `checkDetails` function raise an exception by setting
the `raiseExn` variable to `true` -- the default is `false`.

