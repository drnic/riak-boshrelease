# riak-boshrelease - BOSH Release

This project is a BOSH release for `riak-boshrelease`.

## Development with Vagrant

This project includes development support within Vagrant using [bosh-solo](http://drnic.github.com/bosh-solo)

```
$ bosh create release

$ vagrant up
...
[default] Booting VM...
[default] Waiting for VM to boot. This can take a few minutes.
[default] VM booted and ready for use!
[default] Mounting shared folders...
[default] -- bosh-src: /bosh
[default] -- v-root: /vagrant

$ vagrant ssh
```

Inside the VM:

```
[inside vagrant as vagrant user]
sudo su -

[inside vagrant as root user]
apt-get install curl git-core -y

curl -L https://get.smf.sh | sh
source /etc/profile.d/sm.sh
sm ext install bosh-solo git://github.com/drnic/bosh-solo.git
sm bosh-solo install_dependencies
source /etc/profile.d/rvm.sh
rvm 1.9.3 --default

cd /vagrant/
sm bosh-solo update examples/dev-solo.yml
```

This process will take some time to install Ubuntu packages (during `install_dependencies`) and the source packages within this release.

After that, development is very quick and responsive.

### Deploying new development releases

Each time you change your bosh release you can quickly deploy it into the VM:

```
[outside vagrant within the project]
$ bosh create release

[inside vagrant as root user]
cd /vagrant/
sm bosh-solo update examples/dev-solo.yml
```

All logs will be sent to the terminal so you can watch for any errors as quickly as possible.

```
[inside vagrant as root user]
sm bosh-solo tail_logs
```

### Finalizing a release

If you create a final release `bosh create release --final`, you must immediately create a new development release. Yeah, this is a bug I guess.

```
[outside vagrant]
bosh create release --final
bosh create release

[inside vagrant as vcap user]
/vagrant/scripts/update examples/puma_migrations_postgres.yml
```


### Alternate configurations

This BOSH release is configurable during deployment with properties. 

Please maintain example scenarios in the `examples/` folder.

To switch between example scenarios, run `sm bosh-solo update examples/FILE.yml` with a different example scenario.
