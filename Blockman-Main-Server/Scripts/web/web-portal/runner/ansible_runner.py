#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
from collections import namedtuple
from tempfile import NamedTemporaryFile
from ansible.inventory.manager import InventoryManager
from ansible.vars.manager import VariableManager
from ansible.parsing.dataloader import DataLoader
from ansible.executor import playbook_executor
from ansible.utils.display import Display
from callbacks.play_logger import ServiceTaskLogCallback, PlayBookResultsCollectorWithColors

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


def DefaultOptions(remote_user):
    return Options(connection='smart',
                   remote_user=remote_user,
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


def DefaultSudoOptions():
    return Options(
        connection='smart',  # Need a connection type "smart" or "ssh"
        become=True,
        become_user='ubuntu',
        become_method='sudo'
    )


class Runner(object):

    def __init__(self, hostnames, playbook, run_data, remote_user, options=None, playbook_dir=None, become_pass=None):
        self.run_data = run_data
        self.options = options and options or DefaultOptions(remote_user)

        # Set global verbosity
        self.display = Display()
        self.display.verbosity = self.options.verbosity
        # Executor appears to have it's own
        # verbosity object/setting as well
        playbook_executor.verbosity = self.options.verbosity

        # Become Pass Needed if not logging in as user root
        passwords = {'become_pass': become_pass}

        # Gets data from YAML/JSON files
        self.loader = DataLoader()

        host_content = """[%s]
%s
""" % (run_data['service'], "\n".join(hostnames))
        print host_content
        # Parse hosts, I haven't found a good way to
        # pass hosts in without using a parsed template :(
        # (Maybe you know how?)
        self.hosts = NamedTemporaryFile(delete=False)
        self.hosts.write(host_content)
        self.hosts.flush()
        self.hosts.close()

        # This was my attempt to pass in hosts directly.
        #
        # Also Note: In py2.7, "isinstance(foo, str)" is valid for
        #            latin chars only. Luckily, hostnames are
        #            ascii-only, which overlaps latin charset
        # if isinstance(hostnames, str):
        ##     hostnames = {"customers": {"hosts": [hostnames]}}

        # Set inventory, using most of above objects

        print self.hosts.name
        self.inventory = InventoryManager(loader=self.loader, sources=self.hosts.name)

        # All the variables from all the various places
        self.variable_manager = VariableManager(loader=self.loader, inventory=self.inventory)
        self.variable_manager.extra_vars = self.run_data

        # Playbook to run. Assumes it is
        # local to this python file
        pb_dir = os.path.dirname(__file__)
        if playbook_dir:
            pb_dir = playbook_dir
        playbook = "%s/%s" % (pb_dir, playbook)

        print playbook, run_data, self.options

        # Setup playbook executor, but don't run until run() called
        self.pbex = playbook_executor.PlaybookExecutor(
            playbooks=[playbook],
            inventory=self.inventory,
            variable_manager=self.variable_manager,
            loader=self.loader,
            options=self.options,
            passwords=passwords)
        self.pbex._tqm._stdout_callback = PlayBookResultsCollectorWithColors(self.run_data['logfile'])

    def run(self):
        # Results of PlaybookExecutor
        self.pbex.run()
        stats = self.pbex._tqm._stats

        # Test if success for record_logs
        run_success = True
        hosts = sorted(stats.processed.keys())
        for h in hosts:
            t = stats.summarize(h)
            print 'ansible run summarize: ', h, t
            if t['unreachable'] > 0 or t['failures'] > 0:
                run_success = False

        # Remove created temporary files
        os.remove(self.hosts.name)

        return stats
