#!/usr/bin/env python

import os
from collections import namedtuple
from ansible.parsing.dataloader import DataLoader
from ansible.inventory.manager import InventoryManager
from ansible.vars.manager import VariableManager
from ansible.executor import playbook_executor
from ansible.utils.display import Display

class Options(object):
    def __init__(self, remote_user, private_key_file):
        self.remote_user = remote_user
        self.private_key_file = private_key_file
        self.become_method = 'sudo'
        self.become_user = 'root'
        self.forks = 5
        self.listhosts = None
        self.listtasks = None
        self.listtags = None
        self.syntax = None
        self.module_path = None
        self.check = None
        self.check_mode = None
        self.become = None
        self.diff = False
        self.verbosity=0
        self.connection='ssh'

if __name__ == "__main__":
    loader = DataLoader()

    inventory = InventoryManager(
        loader=loader, 
        sources='/opt/inventories/{inventory}'.format(inventory=os.environ['ANSIBLE_INVENTORY'])
    )

    variable_manager = VariableManager(loader=loader, inventory=inventory)
   
    options = Options(os.environ['ANSIBLE_USER'], '/opt/keys/{key}'.format(key=os.environ['ANSIBLE_SSH_KEY']))

    executor = playbook_executor.PlaybookExecutor(
        playbooks=['/opt/playbooks/{playbook}.yml'.format(playbook=os.environ['ANSIBLE_PLAYBOOK'])], 
        inventory=inventory, 
        variable_manager=variable_manager,
        loader=loader, 
        options=options,
        passwords={}
    )

    executor.run()