#!/usr/bin/env roundup

describe "run riak in dev/solo mode"

set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables
# set -x

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
  example=${release_path}/examples/dev-solo.yml
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

it_runs_the_four_riak_dev_processes() {
  expected='bin/beam -K'
  ps ax | grep "${expected}" | grep -v 'grep'
  test $(ps ax | grep "${expected}" | grep -v 'grep' | wc -l) = 4
}

# https://wiki.basho.com/Building-a-Development-Environment.html#Test-the-cluster-and-add-some-data-to-verify-the-cluster-is-working
it_verifies_the_cluster_is_working() {
  curl -I "http://127.0.0.1:8091/stats"
  test $(curl -I "http://127.0.0.1:8091/stats" 2>&1 | grep 'HTTP/1.1 200 OK' | wc -l) = 1
}

it_runs_riak_admin_test_cycle() {
  result=$(/var/vcap/packages/riak-dev/dev2/bin/riak-admin test)
  expected="Successfully completed 1 read/write cycle to 'dev2@127.0.0.1'"
  test "${expected}" = "${result}"
}