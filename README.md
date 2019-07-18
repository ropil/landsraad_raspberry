# landsraad_raspberry
Raspberry playbooks, scriplets and mementos for setting up a productivity cluster.

## Use case(s)

### `landsraad_rpi_ansibledeploy.yml`
Ansible playbook with initial deployment of python and sudo on fresh raspberry ArchlinuxARM install, from upstream `.tgz`. Requires default user login credentials, such as `archarm_variables.yml`.

Sample execution;

```sh
ansible-playbook -i hosts --extra-vars '@archarm_variables.yml' landsraad_rpi_ansibledeploy.yml
```
