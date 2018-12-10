# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative 'consul_helper.rb'

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
  ##  This example uses three boxes. instance5, instance6, and instance7. 
    (5..7).each do |i|
        config.vm.define "instance#{i}" do |server|
            server.vm.box = "bento/centos-7.5"
            server.vm.box_version = "201805.15.0"
            server.vm.hostname = "instance#{i}"
            server.vm.network :private_network, ip: "192.168.13.3#{i}"

            server.vm.provision "ansible_local" do |ansible|
                ansible.playbook = "/vagrant/playbooks/prereqs.yaml"
            end

            ['consul', 'consul', 'vault', 'vault'].each_slice(2) do |user, primary_group|
                server.vm.provision "ansible_local" do |ansible|
                    ansible.playbook = "/vagrant/playbooks/add_user.yaml"
                    ansible.extra_vars = {'username': user, 'groupname': primary_group}
                end
            end

            server.vm.provision "ansible_local" do |ansible|
                ansible.playbook = "/vagrant/playbooks/consul.yaml"
                ansible.extra_vars = {
                    download_url: get_stable_url('consul'),
                    server_addr: "192.168.13.3#{i}"
                }
            end

            server.vm.provision "ansible_local" do |ansible|
                ansible.playbook = "/vagrant/playbooks/vault.yaml"
                ansible.extra_vars = {download_url: get_stable_url('vault')}
            end

            # server.vm.provision "shell", path: "configureconsul.sh" # sth pending
            
              ##  API Provisioning
            if "#{i}" == "7"
                server.vm.provision "shell", inline: "consul members; curl localhost:8500/v1/catalog/nodes ; sleep 15"
                server.vm.provision "shell", inline: "echo 'Provisioning Consul ACLs via this host: '; hostname"
                server.vm.provision "shell", path: "provision_consul/scripts/acl/consul_acl.sh"
                server.vm.provision "shell", path: "provision_consul/scripts/acl/consul_acl_vault.sh"
            else
                puts 'Not provisioning Consul ACLs via this host: instance%s' % i
            end
        end
    end


    config.vm.define "instance7" do |consul_acl|
#        consul_acl.vm.provision "shell", preserve_order: true, inline: "echo 'Provisioning Consul ACLs via this host: '; hostname"
#        consul_acl.vm.provision "shell", preserve_order: true, path: "provision_consul/scripts/acl/consul_acl.sh"
#        consul_acl.vm.provision "shell", preserve_order: true, path: "provision_consul/scripts/acl/consul_acl_vault.sh"
    end

    (5..7).each do |i|
        config.vm.define "instance#{i}" do |vault|
            vault.vm.provision "shell", preserve_order: true, path: "configurevault.sh"
            vault.vm.provision "shell", preserve_order: true, inline: "sudo systemctl enable vault.service"
            vault.vm.provision "shell", preserve_order: true, inline: "sudo systemctl start vault"
        end
    end

  ##  Consul ACL Configuration
  ##  You'll notice that Consul ACL bootstrapping only succeeds on the first VM.
  ##  Choice of instance5 is not arbitrary. It could be done from within any instance
  ##  running one of the members of the Consul cluster, but instance5
  ##  gets provisioned first.

  ##  Vault's start may only happen after Consul ACL Configuration, because
  ##  it requires a Consul ACL to exist on a running Consul Cluster.

  ##  DB Secret backend
    config.vm.define "db" do |db|
        db.vm.box = "bento/centos-7.5"
        db.vm.box_version = "201805.15.0"
        db.vm.network :private_network, ip: "192.168.13.187"
        db.vm.provision "ansible_local" do |ansible|
            ansible.playbook = "/vagrant/playbooks/prereqs.yaml"
        end
        db.vm.provision "ansible_local" do |ansible|
            ansible.playbook = "/vagrant/playbooks/mariadb.yaml"
            ansible.extra_vars = {'enable_external_conn': true, 'add_root_priv': !ARGV.include?('provision')}
        end
    end
end
