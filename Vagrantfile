
############## CONFIGURATION OPTIONS ################

# Domain to use
domain="myapp.proj" 
# Port to use
domain_port="80"
# Domain to use in admin
admin_domain="myapp.proj"
# Port to use in admin
admin_domain_port="2013"
# MySQL root password
mysql_root_password="vagrant"
# MySQL password
mysql_username="myapp" 
# MySQL password
mysql_password="myapp-password"
# Database name 
mysql_database="myapp"

############## END OF CONFIGURATION - STOP EDITING ##############


Vagrant.configure("2") do |config|

  # define the box name
  config.vm.box = "precise32"

  # define the box url in case Vagrant needs to download it
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"
  
  # define box ip address and host
  config.vm.hostname = domain
  config.vm.network :private_network, ip: "33.33.33.20"
  
  config.vm.provision :hostmanager

  # set file permissions
  config.vm.synced_folder "./", "/var/www", id: "vagrant-root", :nfs => false, owner: "www-data", group: "www-data"
  

  # hostmanager options
  config.hostmanager.enabled            = true
  config.hostmanager.manage_host        = true
  config.hostmanager.ignore_private_ip  = false
  config.hostmanager.include_offline    = true
  config.hostmanager.aliases 			= ["www."+domain]

  # enable the bootstrap-script with arguments
  config.vm.provision "shell" do |s|
    s.path = "bootstrap.sh"
    s.args   = [domain,domain_port,admin_domain,admin_domain_port,mysql_root_password,mysql_username,mysql_password,mysql_database]
  end

end
