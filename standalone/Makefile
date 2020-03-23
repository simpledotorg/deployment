hosts = icmr/playground
password_file = ~/.password_file
export ANSIBLE_CONFIG = ansible/ansible.cfg

.PHONY: help init all update-ssh-keys
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
    print "usage: make [target] hosts=<icmr/playground>\n\n"; \
    for ( sort keys %help ) { \
        print "$$_:\n"; \
        printf("  %-20s %s\n", $$_->[0], $$_->[1]) for @{$$help{$$_}}; \
        print "\n"; \
    }

help: ##@Miscellaneous Show this help.
	@perl -e '$(HELP_FUNC)' $(MAKEFILE_LIST)

init: ##@Setup Install ansible plugins
	ansible-galaxy install -r requirements.yml

all: ##@Setup Install simple-server on hosts. Runs the all.yml playbook
	ansible-playbook --vault-id $(password_file) ansible/$@.yml -i hosts/$(hosts)

update-ssh-keys: ##@Utilities Update ssh keys on boxes. Add keys to `ansible/roles/ssh/` under the appropriate environment
	ansible-playbook --vault-id $(password_file) ansible/setup.yml -i hosts/$(hosts) --tags ssh

update-app-config: ##@Utilities Update app config .env file
	ansible-playbook --vault-id $(password_file) ansible/deploy.yml -i hosts/$(hosts) --tags update-app-config

restart-passenger: ##@Utilities Restart passenger
	ansible-playbook --vault-id $(password_file) ansible/setup.yml -i hosts/$(hosts) -l webservers --tags restart-passenger
