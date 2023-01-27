#!/bin/sh
set -e

bin/rails db:migrate
bin/rails db:seed

rm -f tmp/pids/server.pid && bin/rails s
