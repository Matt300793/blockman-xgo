#!/usr/bin/env python2

from collections import namedtuple
from ansible.parsing.dataloader import DataLoader
from ansible.vars.manager import VariableManager
from ansible.inventory.manager import InventoryManager
from ansible.executor.playbook_executor import PlaybookExecutor

loader = DataLoader()

inventory = InventoryManager(loader=loader, sources=['/home/console/webservice-dev/web-portal/hosts-webservice'])
variable_manager = VariableManager(loader=loader, inventory=inventory)
variable_manager.extra_vars = {
    'service': 'game-service',
    'action': 'start',
    'profile_name': 'ningxia-dev',
    'jvm_max_heap_memory': 1000,
    'jvm_min_heap_memory': 1000
}

passwords = {}

Options = namedtuple('Options',
                     ['connection',
                      'remote_user',
                      'ask_sudo_pass',
                      'verbosity',
                      'ack_pass',
                      'module_path',
                      'forks',
                      'become',
                      'become_method',
                      'become_user',
                      'check',
                      'listhosts',
                      'listtasks',
                      'listtags',
                      'syntax',
                      'sudo_user',
                      'sudo',
                      'diff'])
options = Options(connection='smart',
                  remote_user=None,
                  ack_pass=None,
                  sudo_user=None,
                  forks=5,
                  sudo=None,
                  ask_sudo_pass=False,
                  verbosity=5,
                  module_path=None,
                  become=None,
                  become_method=None,
                  become_user=None,
                  check=False,
                  diff=False,
                  listhosts=None,
                  listtasks=None,
                  listtags=None,
                  syntax=None)

playbook = PlaybookExecutor(playbooks=['/home/console/webservice-dev/web-portal/playbook/yml/service.yml'], inventory=inventory,
                            variable_manager=variable_manager,
                            loader=loader, options=options, passwords=passwords)
result = playbook.run()
stats = playbook._tqm._stats

# Test if success for record_logs
run_success = True
hosts = sorted(stats.processed.keys())
for h in hosts:
    t = stats.summarize(h)
    print t
    if t['unreachable'] > 0 or t['failures'] > 0:
        run_success = False

print '=============stats==================='
print result
print run_success
print stats
