hosts = sample/playground
password_file = ~/.vault_password_et
branch = master
export ANSIBLE_CONFIG = ansible/ansible.cfg
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

.PHONY: help init all deploy ship update-ssh-keys update-app-config restart-passenger restart-sidekiq
# HELP sourced from https://gist.github.com/prwhite/8168133

# Add help text after each target name starting with '\#\#'
# A category can be added with @category
HELP_FUNC = \
    %help; \
    while(<>) { \
        if(/^([a-z0-9_-]+):.*\#\#(?:@(\w+))?\s(.*)$$/) { \
            push(@{$$help{$$2}}, [$$1, $$3]); \
        } \
    }; \
    print "usage: make [target] hosts=<sample/playground>\n\n"; \
    for ( sort keys %help ) { \
        print "$$_:\n"; \
        printf("  %-20s %s\n", $$_->[0], $$_->[1]) for @{$$help{$$_}}; \
        print "\n"; \
    }

help: ##@Miscellaneous Show this help.
	@perl -e '$(HELP_FUNC)' $(MAKEFILE_LIST)

init: ##@Setup Install ansible plugins and dependencies
	ansible-galaxy install -r ansible/requirements.yml
	ansible-galaxy collection install -r ansible/requirements.yml -p ./
	pip install jmespath

all: ##@Setup Install simple-server on hosts. Runs the all.yml playbook
	ansible-playbook --vault-id $(password_file) ansible/$@.yml -i hosts/$(hosts)

deploy: ship restart-passenger ##@Deploy Deploy simple-server/master on hosts.

ship: ##@Deploy Ship simple-server/master to hosts. Runs an ansitrano deploy
	ansible-playbook --vault-id $(password_file) ansible/deploy.yml -i hosts/$(hosts) --extra-vars="ansistrano_git_branch=$(branch)"

update-ssh-keys: ##@Utilities Update ssh keys on boxes. Add keys to `ansible/roles/ssh/` under the appropriate environment
	ansible-playbook --vault-id $(password_file) ansible/setup.yml -i hosts/$(hosts) --tags ssh

update-app-config: ##@Utilities Update app config .env file
	ansible-playbook --vault-id $(password_file) ansible/deploy.yml -i hosts/$(hosts) --tags update-app-config

update-ssl-certs: ##@Utilities Update the SSL certs. Add the appropriate certs under the encrypted ssl-vault.yml
	ansible-playbook --vault-id $(password_file) ansible/load_balancing.yml -i hosts/$(hosts) --tags load_balancing

restart-passenger: ##@Utilities Restart passenger
	ansible-playbook --vault-id $(password_file) ansible/setup.yml -i hosts/$(hosts) -l webservers --tags restart-passenger

restart-sidekiq: ##@Utilities Restart sidekiq
	ansible-playbook --vault-id $(password_file) ansible/deploy.yml -i hosts/$(hosts) -l sidekiq --tags restart-sidekiq
