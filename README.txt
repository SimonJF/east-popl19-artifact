# Session Types without Tiers: Implementation

## Introduction

This is the artifact for Exceptional Asynchronous Session Type: Session Types
without Tiers.

The artifact contains the modified Links programming language with session
types and exceptions, and several example applications. These are packaged in
a Docker image, and we have included scripts to launch the interpreter and the
examples.

We provide several example Links programs:

  * the cancellation examples in Section 2.1 of the paper
    (examples/paper-examples)
  * examples of incorrect implementations of the 2FA server caught by session types in Links
    (examples/caught-errors)
  * examples of distributed exception handling
    (examples/distributed-exceptions)
  * the chat server example
    (examples/chatserver)
  * a web-based version of the two factor authentication example
    (examples/two-factor)

An overview of the Links syntax can be found in `links/doc/quick-help.pod`.

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

## Changing the port

By default, the Links server will listen on port 8080. If you wish to change
this port to a different value, set the `LINKS_PORT` environment variable:

  export LINKS_PORT=9001

In the remainder of the guide, we will assume the default port of 8080.

## Differences between EGV and Links

The paper describes a core calculus, EGV, which extends the GV core functional
programming language with exception handling constructs. EGV is a purely
linear calculus, which does not (without extension) handle the integration of
linear and unrestricted types.

In contrast, Links is designed to be used as a general-purpose programming
language. It integrates linearity, polymorphism, unrestricted types, and
session types via an approach based on subkinding, as pioneered by Mazurak et
al. (2012). The core type system of Links with session types is described by
Lindley & Morris (2017).

The constructs and semantics of exception handling are the same as in the
paper. As the paper describes, `close` is un-needed in Links, since endpoints
of type `End` are affine, as opposed to linear in EGV.

Links supports communication and exception handling in the distributed
setting, as described in the paper. Distributed communication is achieved
through WebSockets, which have TCP ordering semantics as defined in the RFC
(Fette & Melnikov, 2011). We make the assumption that the OCaml implementation
of WebSockets faithfully implements the RFC.

## Implementation of exception handlers using linear effect handlers

As described in the paper, exception handlers are implemented via a
translation into linear effect handlers.

Using the typing rule for try-in-otherwise as described in the paper as
an input to a translation into linear effect handlers is unsound, as it
allows possibly-linear variables to be used twice, as there is no reason
in the more general setting of effect handlers that an exception
couldn't be invoked twice.

  G1 |- L : A   G2, x : A |- M : B    G2 |- N : B
  -------------------------------------------------
     G1, G2 |- try L as x in M otherwise N : B

Instead, the typechecker implements a more restrictive typing
rule which only allows a single variable in the typing of the
success continuation:

  G |- L : A   x : A |- M : B     |- N : B
  ------------------------------------------
    G |- try L as x in M otherwise N : B

Thankfully, the full power of the first rule can be restored
through the use of a simple macro-translation, performed in
`desugarExceptionHandlers.ml`.

  try L as x in M otherwise N
    -->
  switch (try L as x in Just(x) otherwise Nothing) {
    case Just(x) -> M
    case Nothing -> N
  }

This detail is only relevant for the implementation; all of the
properties described in the paper are true in the presence of the more
liberal rule.

## Sample evaluation workflow

  1. Ensure you have `docker` installed.
     See: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04
  2. Ensure you have added yourself to the `docker` group: `sudo usermod -a -G
     docker <username>`. You will need to log back in to see the permissions take effect.
  3. Run `./prepare.sh` to install the image and prepare the docker container
     (and you might wish to grab a coffee while this churns through)
  4. Run the chatserver example by invoking `./run-chatserver.sh` and follow the
     instructions in the "Chatserver" section later in this guide
     When you're finished, press Ctrl-C to kill the server process.
  5. Run the 2FA example by invoking `./run-two-factor.sh` and follow the
     instructions in the "Two-factor authentication example" section later in
     this guide.
  6. Run the smaller examples by invoking `./run-example.sh`. Note that
     the "Distributed Exceptions" examples require navigating to
     `http://localhost:8080` in your browser.
  7. Run the unit tests by invoking `./run-unit-tests.sh`. If you wish
     to look at the unit tests, you can get to them via the `unit-tests`
     symlink.
  8. Remove any leftover containers and the image by running
     `./cleanup.sh`

You can also run your own examples by adding the file to the `custom_examples`
directory and running `./run-custom.sh <example file name>`.
For example, try running `./run-custom.sh helloworld.links`.

## Installing Links
We strongly recommend using the Docker image. If you do not wish to use Docker
however, you can install Links from source on an Ubuntu 16.04 install as
follows:

  1. Install the system dependencies using `sudo apt install opam m4 libssl-dev pkg-config`
  2. Run `opam init`
  3. Run `opam switch 4.06.1`
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

### Chatserver

To run the chat server example, run
  ```
    ./run-chatserver.sh
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
    ./run-two-factor.sh
  ```

Again, navigate to `http://localhost:8080`.

The correct credentials are `User` and `hunter2`.
You will then be prompted for a key -- the "algorithm" for calculating the
response is just to add one to the challenge key you are presented.

The `raiseExn` variable in `two-factor/twoFactor.links` controls whether or
not the server raises an exception when calling `checkDetails`, as described
in the introduction of the paper.  You can make the `checkDetails` function
raise an exception by setting the `raiseExn` variable to `true` -- the default
is `false`.

### Smaller examples

Running ./run-example.sh will provide you with an interactive script
allowing you to launch each of the smaller examples. Alternatively, you can run
./run-example.sh with an argument to launch an example by path.

## Future Work

Future work for the artifact includes investigating whether WebRTC (Bergkvist
et al., 2012) could be used for "true" client-to-client communication, as
opposed to routing messages through the server, and compliling client code to
WebAssembly instead of JavaScript.

## References

Bergkvist, A., Burnett, D. C., Jennings, C., Narayanan, A., & Aboba, B. (2012).
  Webrtc 1.0: Real-time communication between browsers.
  Working draft, W3C, 91.

Fette, I., & Melnikov, A. (2011).
  The WebSocket protocol.
  RFC 6455.

Lindley, S. and Morris, J. G. (2017).
 Lightweight functional session types.
 Behavioural Types: from Theory to Tools, page 265.

Mazurak, K., Zhao, J., and Zdancewic, S. (2010).
 Lightweight linear types in System F°.
 In TLDI, pages 77--88. ACM.

