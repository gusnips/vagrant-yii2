# -*- mode: ruby -*-
# vi: set ft=ruby :

############## CONFIGURATION OPTIONS ################

# box domains. First one used as box hostname, but defined mostly to use in in hostmanager plugin, if enabled.
domains= ["yii2app.dev","www.yii2app.dev","admin.yii2app.dev"]

# box IP
ip= "33.33.33.34"

# MySQL root password
mysql_root_password= "vagrant"

############## END OF CONFIGURATION - STOP EDITING ##############

Vagrant.configure("2") do |config|

    # define the box name and url in case Vagrant needs to download it
    # 64 bits box commented
    config.vm.box = "precise32"
    #config.vm.box = "precise64"

    config.vm.box_url = "http://files.vagrantup.com/precise32.box"
    #config.vm.box_url = "http://files.vagrantup.com/precise64.box"

    # define box ip address and host
    config.vm.hostname = domains[0]
    config.vm.network :private_network, ip: ip

    # set file permissions
    config.vm.synced_folder "./", "/var/www", id: "vagrant-root", :nfs => false, owner: "www-data", group: "www-data"

    # enable the bootstrap-script with arguments
    config.vm.provision "shell" do |s|
        s.path = "bootstrap.sh"
        s.args = [mysql_root_password, ip, domains.join(",")]
    end

    # [hostmanager plugin](https://github.com/smdahlen/vagrant-hostmanager)
    # To install type:
    # vagrant plugin install vagrant-hostmanager
    # and then uncomment the following lines

    #config.vm.provision :hostmanager
    #config.hostmanager.enabled            = true
    #config.hostmanager.manage_host        = true
    #config.hostmanager.ignore_private_ip  = false
    #config.hostmanager.include_offline    = true
    #config.hostmanager.aliases            = domains

    #define max cpu usage and add more memory, if needed
    #config.vm.provider "virtualbox" do |v|
        #v.customize ["modifyvm", :id, "--cpuexecutioncap", "80"]
        #v.customize ["modifyvm", :id, "--memory", "1666"]
        #fix for virtualbox 64bits when no vt-x. Requires virtualbox v4.3+
        #See https://forums.virtualbox.org/viewtopic.php?f=6&t=58820
        #v.customize ["modifyvm", :id, "--longmode", "off"]
    #end

end
