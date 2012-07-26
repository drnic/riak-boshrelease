#!/usr/bin/env roundup

describe "run single node in production/multivm mode"

set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables

[ "$(whoami)" != 'root' ] && ( echo ERROR: run as root user; exit 1 )

cd /vagrant/ # need to hardcode as roundup overrides $0
release_path=$(pwd)

rm -rf /tmp/before_all_run_already

before_all() {
  echo "|"
  echo "| Stopping any existing jobs"
  echo "|"
  sm bosh-solo stop

  echo "|"
  echo "| Deleting existing store folder"
  echo "|"
  rm -rf /var/vcap/store

  # update deployment with example properties
  example=${release_path}/examples/multivm-4.yml
  sm bosh-solo update ${example}

  # wait for everything to be finished
  # TODO: necessary?
  sleep 15
  
  # show last 20 processes (for debugging if test fails)
  ps ax | tail -n 20
}

# before() is only hook into roundup
# TODO add before_all() to roundup
before() {
  if [ ! -f /tmp/before_all_run_already ]
  then
    before_all
    touch /tmp/before_all_run_already
  fi
}

it_runs_the_riak_processes() {
  expected='bin/beam -K'
  ps ax | grep "${expected}" | grep -v 'grep'
  test $(ps ax | grep "${expected}" | grep -v 'grep' | wc -l) = 1
}

it_verifies_the_node_is_working() {
  curl -I "http://127.0.0.1:8098/stats"
  test $(curl -I "http://127.0.0.1:8098/stats" 2>&1 | grep 'HTTP/1.1 200 OK' | wc -l) = 1
}

it_runs_riak_admin_test_cycle() {
  result=$(/var/vcap/packages/riak/rel/bin/riak-admin test)
  expected="Successfully completed 1 read/write cycle to 'riak@127.0.0.1'"
  test "${expected}" = "${result}"
}

it_binds_to_0_0_0_0() {
  test $(cat /var/vcap/packages/riak/rel/etc/app.config | grep 0.0.0.0 | wc -l) = 3
}

it_does_not_bind_to_127_0_0_1() {
  test $(cat /var/vcap/packages/riak/rel/etc/app.config | grep 127.0.0.1 | wc -l) = 0
}

# OR should it bind to its public IP? private IP?