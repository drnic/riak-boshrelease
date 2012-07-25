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

... installs lots of stuff...

$ vagrant ssh
```

Inside the VM:

```
[inside vagrant as vagrant user]
sudo su -

[inside vagrant as root user]
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

### Multi-VM development within Vagrant

To boot up Vagrant into multi-VM mode:

```
MULTIVM=4 vagrant up
```

You can then shell into each VM via its name (rel1, rel2, rel3, ...).

```
MULTIVM=4 vagrant ssh rel1
```

### Finalizing a release

If you create a final release `bosh create release --final`, you must immediately create a new development release. Yeah, this is a bug I guess.

```
[outside vagrant]
bosh create release --final
bosh create release

[inside vagrant as vcap user]
/vagrant/scripts/update examples/dev-solo.yml
```


### Alternate configurations

This BOSH release is configurable during deployment with properties. 

Please maintain example scenarios in the `examples/` folder.

To switch between example scenarios, run `sm bosh-solo update examples/FILE.yml` with a different example scenario.

## Uploading to BOSH

Once you have a BOSH release that you like, you can upload it to BOSH and deploy it.

```
bosh upload release
bosh deployment path/to/manifest.yml
bosh deploy
```

Example `properties` for your `manifest.yml` can be taken from the examples in `examples\`