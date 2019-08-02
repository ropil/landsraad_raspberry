# landsraad_raspberry
Raspberry playbooks, scriplets and mementos for setting up a productivity cluster.

## Use case(s)

### `landsraad_rpi_ansibledeploy.yml`
Ansible playbook with initial deployment of python and sudo on fresh raspberry ArchlinuxARM install, from upstream `.tgz`. Requires default user login credentials, such as `archarm_variables.yml`.

#### Sample playbook execution

```sh
ansible-playbook -i archarm_hosts --extra-vars '@archarm_variables.yml' landsraad_rpi_ansibledeploy.yml
```

### `landsraad_rpi_userdeploy.yml`
Setup default user for cluster orchestration, with ssh key authentication. Parameters needs to be edited, adding encrypted password, and creating cluster ssh key files.

Cluster specific parameters are set in `landsraad_variables.yml` (default) and `landsraad_variables_<host>.yml` (host specific). Host specific files are named with `<host>` being the same corresponding identifier in the `archarm_hosts` inventory file. ArchlinuxARM default parameters are in `archarm_variables.yml`.

Passwords are encrypted best using `python-passlib` on the configuring host, which are then edited into and saved as `devops_password`, in the default or host specific variable files;

```sh
pacman -S python-passlib
python -c "from passlib.hash import sha512_crypt; import getpass; print(sha512_crypt.using(rounds=5000).hash(getpass.getpass()))"
```

A keyfile must be generated and stored in a file recognized by the playbook, which here defaults to `~/.ssh/id_rsa_landsraad`. Execute something similar to the following, saving the results appropriately named;

```sh
ssh-keygen -t rsa -b 4096 -C "$(whoami)@$(hostname)-$(date -I)"
```

#### Sample playbook execution

```sh
ansible-playbook -i archarm_hosts --extra-vars '@archarm_variables.yml' landsraad_rpi_userdeploy.yml
```

### `landsraad_rpi_userdel.yml`
Remove default user and update root password to custom host/cluster password.

Default ArchARM and custom cluster variables are stored in `archarm_variables.yml` and `landsraad_variables.yml` respectively. Custom host specific variables are in `landsraad_variables_<host>.yml`, if needed. Passwords needs to be encrypted when stored in `_variables*.yml` files, see `landsraad_rpi_userdeploy.yml` use case above.

A cluster hosts file is needed since `ansible_user` has changed after a new user has been deployed; this cluster inventory file is `landsraad_hosts`, which needs to be edited appropriately.

If host specific cluster user names are used, one can load the `landsraad_variables_<host>.yml` file with `--extra-vars`, and execute on each host separately using a for loop or similar.

#### Sample playbook execution

```sh
ansible-playbook -i landsraad_hosts --extra-vars '@landsraad_variables.yml' landsraad_rpi_userdel.yml
```

### `landsraad_rpi_network.yml`
Update sshd, hostname(s) and reboot system; Set no root login in `sshd_conf`, disable `.service` and enable `.socket`, set hostname and build `/etc/hosts` according to inventory file.

In this case the `landsraad_hosts` inventory file defines the "FQDN" and IP of the hosts in the cluster, and therefore the inventory is used to build the `/etc/hosts` files.

#### Sample playbook execution

```sh
ansible-playbook -i landsraad_hosts --extra-vars '@landsraad_variables.yml' landsraad_rpi_network.yml;
```

### `landsraad_rpi_ntp.yml`
Install NTPD, configure for Swedish servers and start service.

#### Sample playbook execution

```sh
ansible-playbook -i landsraad_hosts --extra-vars '@landsraad_variables.yml' landsraad_rpi_ntp.yml;
```

### `landsraad_rpi_iptables.yml`
Install, configure and start iptables to support GlusterFS.

This playbook is **not idempotent**, as it will clear all firewall tables, set a number of rules and then *always* write it out to `/etc/iptables/iptables.rules`. Future goldplating might include templates and other stuff to make it more ansi(sensi)ble.

#### Sample playbook execution

```sh
ansible-playbook -i landsraad_hosts --extra-vars '@landsraad_variables.yml' landsraad_rpi_iptables.yml;
```

## Pinging
After successfully running the above playbooks, in order, you should be able to ping all hosts with the following command;

```sh
ansible -i landsraad_hosts --extra-vars '@landsraad_variables.yml' all -m ping;
```
