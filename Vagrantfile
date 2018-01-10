# -*- mode: ruby -*-
# vi: set ft=ruby :

PROJECT_NAME = ENV['PROJECT_NAME'] || File.basename(File.expand_path(File.dirname(__FILE__)))

#
# Environment variables that can be overriden on vagrant up
#
VM_CPUS = ENV['VM_CPUS'] || 2
VM_CPU_CAP = ENV['VM_CPU_CAP'] || 100 
VM_MEMORY = ENV['VM_MEMORY'] || 1024
VM_GUI = ENV['VM_GUI'] == 'true' ? true : false
VB_GUEST = ENV['VB_GUEST'] == 'true' ? true : false
VM_VB_NATDNSHOSTRESOLVER = ENV['VM_VB_NATDNSHOSTRESOLVER'] || 'off'
# Set env var ANSIBLE_GALAXY_FORCE='' to NOT force install of roles
ANSIBLE_GALAXY_FORCE = ENV['ANSIBLE_GALAXY_FORCE'] || "--force"
HTTP_PROXY = ENV['VAGRANT_HTTP_PROXY'] || ENV['HTTP_PROXY']
HTTPS_PROXY = ENV['VAGRANT_HTTPS_PROXY'] || ENV['HTTP_PROXY']
NO_PROXY = ENV['VAGRANT_NO_PROXY'] || "NO_PROXY"


boxes = [
  {
  :name => "centos",
  :box => "boxcutter/centos7-desktop",
  :cpu => VM_CPU_CAP,
  :ram => VM_MEMORY
  },
  {
  :name => "ubuntu",
  :box => "boxcutter/ubuntu1604-desktop",
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
    if(HTTP_PROXY.nil? || HTTP_PROXY.empty? || HTTP_PROXY == 'null')
      puts "Disabling proxy conf plugin. No proxy settings found."
      config.proxy.enabled = false
    else
      config.proxy.http = HTTP_PROXY
      config.proxy.https = HTTPS_PROXY
      config.proxy.no_proxy = NO_PROXY
    end
  end

  boxes.each do |box|
    config.vm.define box[:name] do |vms|
      vms.vm.box = box[:box]

      @syncfolder_type = 'virtualbox'
      if Vagrant::Util::Platform.windows? then
          syncfolder_type = 'nfs'
      end
      vms.vm.synced_folder '../', '/vagrant', type: syncfolder_type , disabled: false
      
      vms.vm.provider "virtualbox" do |v|
        v.gui = VM_GUI
        v.cpus = VM_CPUS
        v.customize ["modifyvm", :id, "--cpuexecutioncap", box[:cpu]]
        v.customize ["modifyvm", :id, "--memory", box[:ram]]
        v.customize ["modifyvm", :id, "--ioapic", "on"]
        v.customize ["modifyvm", :id, "--natdnshostresolver1", VM_VB_NATDNSHOSTRESOLVER]
      end

      # Work around for epel bug https://bugs.centos.org/view.php?id=13669&nbn=1
      if box[:name].eql? "centos"
        vms.vm.provision "shell",
        inline: "sudo rpm -ivh --replacepkgs https://kojipkgs.fedoraproject.org/packages/http-parser/2.7.1/3.el7/x86_64/http-parser-2.7.1-3.el7.x86_64.rpm"
      end
    
      if box[:name].eql? "ubuntu"
        vms.vm.provision "shell",
        inline: "sudo apt-get update && sudo apt-get -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confnew' install -y -qq build-essential curl git libssl-dev libffi-dev python-dev python-pip"
      end
     
      vms.vm.provision "ansible", type: :ansible_local do |ansible|
        ansible.verbose = "v"
        ansible.install_mode = "pip"
        ansible.version = "2.4.2.0"
        ansible.playbook = "#{PROJECT_NAME}/tests/playbook.yml"
        ansible.galaxy_role_file = "#{PROJECT_NAME}/tests/requirements.yml"
        ansible.galaxy_roles_path = "#{PROJECT_NAME}/tests/roles"
        ansible.galaxy_command = "ansible-galaxy install --ignore-certs --role-file=%{role_file} --roles-path=%{roles_path} #{ANSIBLE_GALAXY_FORCE}"
        ansible.become = true
      end
    end
  end
end

