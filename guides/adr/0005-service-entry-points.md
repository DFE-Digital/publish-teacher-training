# 5. Service Entry Points

Date: 2020-08-13

## Status

Accepted

## Context

Services help us by wrapping and presenting functionality. Typically services
present one piece of functionality, and use a single method to invoke this
functionality. For the sake of consistency, we want to align this "entry point"
so that services can be called the same way.

## Options

### 1. Use "execute" as entry point

We've been using "execute" for some/many of our services so far.

### 2. Use "call" as an entry point

Some of our service have been using `call`, and in informal polling this has
been popular among some devs. This also mimics existing callable Ruby objects,
which may be a good thing.

## Decision

Use option 2, `call`. Additionally, provide both the instance method `#call` and a class
method `.call`, of which the later instantiates the service and calls `#call`.

## Consequences

We'll want to change existing services to make things consistent. This will
improve code maintanibility.
