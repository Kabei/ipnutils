#!/bin/bash

mix deps.get
mix local.rebar --force
mix compile