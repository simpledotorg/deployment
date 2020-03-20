inventory_file = hosts/icmr/playground
password_file = ~/.password_file
export ANSIBLE_CONFIG = ansible/ansible.cfg

init :
	ansible-galaxy install -r requirements.yml

update-ssh-keys:
	ansible-playbook --vault-id $(password_file) ansible/setup.yml -i $(inventory_file) --tags ssh
