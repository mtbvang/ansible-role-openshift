# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# Environment variables that can be overriden on vagrant up
#
VM_CPUS = ENV['VM_CPUS'] || 2
VM_CPU_CAP = ENV['VM_CPU_CAP'] || 80
VM_MEMORY = ENV['VM_MEMORY'] || 1024
VM_GUI = ENV['VM_GUI'] == 'true' ? true : false
VB_GUEST = ENV['VB_GUEST'] == 'true' ? true : false
# Set env var ANSIBLE_GALAXY_FORCE='' to NOT force install of roles
ANSIBLE_GALAXY_FORCE = ENV['ANSIBLE_GALAXY_FORCE'] || "--force"
HTTP_PROXY = ENV['VAGRANT_HTTP_PROXY'] || ENV['http_proxy']
HTTPS_PROXY = ENV['VAGRANT_HTTPS_PROXY'] || ENV['http_proxy']
NO_PROXY = ENV['VAGRANT_NO_PROXY'] || "no_proxy"
OPENSHIFT_PORT_HOST = ENV['OPENSHIFT_PORT_HOST'] || 8453


boxes = [
  {
  :name => "centos",
  :box => "box-cutter/centos73-desktop",
  :version => "2.0.21",
  :cpu => VM_CPU_CAP,
  :ram => VM_MEMORY
  },
  {
  :name => "ubuntu",
  :box => "box-cutter/ubuntu1604-desktop",
  :version => "2.0.26",
  :cpu => VM_CPU_CAP,
  :ram => VM_MEMORY
  },
]

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = VB_GUEST
  end
  
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http     = HTTP_PROXY
    config.proxy.https    = HTTPS_PROXY
    config.proxy.no_proxy = NO_PROXY
  end

  boxes.each do |box|
    config.vm.define box[:name] do |vms|
      vms.vm.box = box[:box]
      
      vms.vm.network "forwarded_port", guest: 8443, host: OPENSHIFT_PORT_HOST  # Openshift console

      vms.vm.provider "virtualbox" do |v|
        v.gui = VM_GUI
        v.cpus = VM_CPUS
        v.customize ["modifyvm", :id, "--cpuexecutioncap", box[:cpu]]
        v.customize ["modifyvm", :id, "--memory", box[:ram]]
        v.customize ["modifyvm", :id, "--ioapic", "on"]
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vms.vm.synced_folder '../', '/vagrant', type: "virtualbox", disabled: false
      end

      if box[:name].eql? "ubuntu-xenial"
        vms.vm.provision "shell",
        inline: "echo 'Installing python 2 required by Ansible.' && sudo apt-get -y install python-minimal"
      end

      vms.vm.provision :ansible do |ansible|
        ansible.verbose = "v"
        ansible.playbook = "vagrant/playbook.yml"
        ansible.galaxy_role_file = "requirements.yml"
        ansible.galaxy_roles_path = "vagrant/roles"
        ansible.galaxy_command = "ansible-galaxy install --ignore-certs --role-file=%{role_file} --roles-path=%{roles_path} #{ANSIBLE_GALAXY_FORCE}"
        ansible.sudo = true
      end
    end
  end

end

