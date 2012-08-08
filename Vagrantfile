Vagrant::Config.run do |config|
  config.vm.box = "lucid64"
  config.vm.box_url = "http://files.vagrantup.com/lucid64.box"

  config.vm.provision :shell, :path => "scripts/vagrant-setup.sh"

  if local_bosh_src = ENV['BOSH_SRC']
    config.vm.share_folder "bosh-src", "/bosh", local_bosh_src
  end

  if ENV['MULTIVM']
    multivm_total = ENV['MULTIVM'].to_i
    multivm_total = 4 if multivm_total < 4
    # create VMs with internal IPs:
    # - 192.168.11
    # - 192.168.12
    # - 192.168.13
    # - 192.168.14
    1.upto(4) do |n|
      config.vm.define "rel#{n}".to_sym do |riak_config|
        riak_config.vm.network :hostonly, "192.168.10.1#{n}"
      end
    end
  end
end
