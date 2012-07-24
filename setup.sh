#!/usr/bin/env bash

set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables
set +x

if [[ ! -f /var/vcap/install_dependencies_complete ]]
then
  echo Installing dependencies for bosh-solo

  sudo apt-get install curl git-core -y
  
  if [[ ! -x /opt/sm/bin/sm ]]
  then
    if [[ ! -f /tmp/smf.sh ]]
    then
      curl -s -L https://get.smf.sh -o /tmp/smf.sh
    fi
    sudo chmod +x /tmp/smf.sh
    sudo sh /tmp/smf.sh
  fi
  sudo /opt/sm/bin/sm ext install bosh-solo git://github.com/drnic/bosh-solo.git
  sudo /opt/sm/bin/sm bosh-solo install_dependencies

  sudo /usr/local/rvm/bin/rvm 1.9.3 --default
  
  sudo mkdir -p /var/vcap
  sudo touch /var/vcap/install_dependencies_complete
fi
