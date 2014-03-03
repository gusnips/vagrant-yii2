Vagrant.configure("2") do |config|

  # define the box name
  config.vm.box = "precise32"

  # define the box url in case Vagrant needs to download it
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  # define box ip address
  config.vm.network "private_network", ip: "33.33.33.20"

  # set file permissions
  config.vm.synced_folder "./", "/var/www", id: "vagrant-root", :nfs => false, owner: "www-data", group: "www-data"

  # enable the bootstrap-script
  config.vm.provision :shell, :path => "bootstrap.sh"

end
