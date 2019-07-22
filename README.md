# landsraad_raspberry
Raspberry playbooks, scriplets and mementos for setting up a productivity cluster.

## Use case(s)

### `landsraad_rpi_ansibledeploy.yml`
Ansible playbook with initial deployment of python and sudo on fresh raspberry ArchlinuxARM install, from upstream `.tgz`. Requires default user login credentials, such as `archarm_variables.yml`.

Sample execution;

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

Sample playbook execution;

```sh
ansible-playbook -i archarm_hosts --extra-vars '@archarm_variables.yml' landsraad_rpi_userdeploy.yml
```
