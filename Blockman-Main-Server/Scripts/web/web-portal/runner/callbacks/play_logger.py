#!/usr/bin/env python
# -*- coding: utf-8 -*-
from datetime import datetime
from ansible.plugins.callback import CallbackBase
import json

class PlayLogger:
    """Store log output in a single object.
    We create a new object per Ansible run
    """

    def __init__(self, logfile):
        self.log = ''
        self.runtime = 0
        self.logfile = logfile
        self.logfile = open(self.logfile, 'a+')

    def append(self, log_line):
        """append to log"""
        print '-a-a-a-', log_line
        self.log += log_line + "\n\n"
        self.logfile.write(log_line + "\n\n")

    def banner(self, msg):
        """Output Trailing Stars"""
        width = 78 - len(msg)
        if width < 3:
            width = 3
        filler = "*" * width
        return "\n%s %s " % (msg, filler)


class ServiceTaskLogCallback(CallbackBase):
    """
    Reference: https://github.com/ansible/ansible/blob/v2.0.0.2-1/lib/ansible/plugins/callback/default.py
    """

    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'stored'
    CALLBACK_NAME = 'database'

    def __init__(self, logfile):
        super(ServiceTaskLogCallback, self).__init__()
        self.logger = PlayLogger(logfile)
        self.start_time = datetime.now()

    def v2_runner_on_failed(self, result, ignore_errors=False):
        delegated_vars = result._result.get('_ansible_delegated_vars', None)

        # Catch an exception
        # This may never be called because default handler deletes
        # the exception, since Ansible thinks it knows better
        if 'exception' in result._result:
            # Extract the error message and log it
            error = result._result['exception'].strip().split('\n')[-1]
            self.logger.append(error)

            # Remove the exception from the result so it's not shown every time
            del result._result['exception']

        # Else log the reason for the failure
        if result._task.loop and 'results' in result._result:
            # item_on_failed, item_on_skipped, item_on_ok
            self._process_items(result)
        else:
            if delegated_vars:
                self.logger.append("fatal: [%s -> %s]: FAILED! => %s" % (result._host.get_name(
                ), delegated_vars['ansible_host'], self._dump_results(result._result)))
            else:
                self.logger.append("fatal: [%s]: FAILED! => %s" % (
                    result._host.get_name(), self._dump_results(result._result)))

    def v2_runner_on_ok(self, result):
        self._clean_results(result._result, result._task.action)
        delegated_vars = result._result.get('_ansible_delegated_vars', None)
        if result._task.action == 'include':
            return
        elif result._result.get('changed', False):
            if delegated_vars:
                msg = "changed: [%s -> %s]" % (result._host.get_name(),
                                               delegated_vars['ansible_host'])
            else:
                msg = "changed: [%s]" % result._host.get_name()
        else:
            if delegated_vars:
                msg = "ok: [%s -> %s]" % (result._host.get_name(),
                                          delegated_vars['ansible_host'])
            else:
                msg = "ok: [%s]" % result._host.get_name()

        if result._task.loop and 'results' in result._result:
            # item_on_failed, item_on_skipped, item_on_ok
            self._process_items(result)
        else:
            self.logger.append(msg)

    def v2_runner_on_skipped(self, result):
        if result._task.loop and 'results' in result._result:
            # item_on_failed, item_on_skipped, item_on_ok
            self._process_items(result)
        else:
            msg = "skipping: [%s]" % result._host.get_name()
            self.logger.append(msg)

    def v2_runner_on_unreachable(self, result):
        delegated_vars = result._result.get('_ansible_delegated_vars', None)
        if delegated_vars:
            self.logger.append("fatal: [%s -> %s]: UNREACHABLE! => %s" % (result._host.get_name(
            ), delegated_vars['ansible_host'], self._dump_results(result._result)))
        else:
            self.logger.append("fatal: [%s]: UNREACHABLE! => %s" % (
                result._host.get_name(), self._dump_results(result._result)))

    def v2_runner_on_no_hosts(self, task):
        self.logger.append("skipping: no hosts matched")

    def v2_playbook_on_task_start(self, task, is_conditional):
        self.logger.append("TASK [%s]" % task.get_name().strip())

    def v2_playbook_on_play_start(self, play):
        name = play.get_name().strip()
        if not name:
            msg = "PLAY"
        else:
            msg = "PLAY [%s]" % name

        self.logger.append(msg)

    def v2_playbook_item_on_ok(self, result):
        delegated_vars = result._result.get('_ansible_delegated_vars', None)
        if result._task.action == 'include':
            return
        elif result._result.get('changed', False):
            if delegated_vars:
                msg = "changed: [%s -> %s]" % (result._host.get_name(),
                                               delegated_vars['ansible_host'])
            else:
                msg = "changed: [%s]" % result._host.get_name()
        else:
            if delegated_vars:
                msg = "ok: [%s -> %s]" % (result._host.get_name(),
                                          delegated_vars['ansible_host'])
            else:
                msg = "ok: [%s]" % result._host.get_name()

        msg += " => (item=%s)" % (result._result['item'])

        self.logger.append(msg)

    def v2_playbook_item_on_failed(self, result):
        delegated_vars = result._result.get('_ansible_delegated_vars', None)
        if 'exception' in result._result:
            # Extract the error message and log it
            error = result._result['exception'].strip().split('\n')[-1]
            self.logger.append(error)

            # Remove the exception from the result so it's not shown every time
            del result._result['exception']

        if delegated_vars:
            self.logger.append("failed: [%s -> %s] => (item=%s) => %s" % (result._host.get_name(
            ), delegated_vars['ansible_host'], result._result['item'], self._dump_results(result._result)))
        else:
            self.logger.append("failed: [%s] => (item=%s) => %s" % (result._host.get_name(
            ), result._result['item'], self._dump_results(result._result)))

    def v2_playbook_item_on_skipped(self, result):
        msg = "skipping: [%s] => (item=%s) " % (
            result._host.get_name(), result._result['item'])
        self.logger.append(msg)

    def v2_playbook_on_stats(self, stats):
        run_time = datetime.now() - self.start_time
        # returns an int, unlike run_time.total_seconds()
        self.logger.runtime = run_time.seconds

        hosts = sorted(stats.processed.keys())
        for h in hosts:
            t = stats.summarize(h)

            msg = "PLAY RECAP [%s] : %s %s %s %s %s" % (
                h,
                "ok: %s" % (t['ok']),
                "changed: %s" % (t['changed']),
                "unreachable: %s" % (t['unreachable']),
                "skipped: %s" % (t['skipped']),
                "failed: %s" % (t['failures']),
            )

            self.logger.append(msg)


class PlayBookResultsCollectorWithColors(CallbackBase):
    CALLBACK_VERSION = 2.0

    def __init__(self, logfile, *args, **kwargs):
        super(PlayBookResultsCollectorWithColors, self).__init__(*args, **kwargs)
        self.task_ok = {}
        self.task_skipped = {}
        self.task_failed = {}
        self.task_status = {}
        self.task_unreachable = {}
        self.task_changed = {}
        self.logfile = logfile
        self.logger = PlayLogger(logfile)
        self.taks_check = {}

    def v2_runner_on_ok(self, result, *args, **kwargs):
        self._clean_results(result._result, result._task.action)
        self.task_ok[result._host.get_name()] = result._result
        delegated_vars = result._result.get('_ansible_delegated_vars', None)
        for remove_key in ('changed', 'invocation', '_ansible_parsed', '_ansible_no_log', '_ansible_verbose_always'):
            if remove_key in result._result:
                del result._result[remove_key]
        if result._task.action in ('include', 'include_role', '_ansible_parsed', '_ansible_no_log'):
            return
        elif result._result.get('changed', False):
            if delegated_vars:
                msg = "<font color='yellow'>changed: [%s -> %s]</font>" % (result._host.get_name(), delegated_vars['ansible_host'])
            else:
                msg = "<font color='yellow'>changed: [%s]</font>" % result._host.get_name()
        else:
            if delegated_vars:
                msg = "<font color='green'>ok: [%s -> %s]</font>" % (result._host.get_name(), delegated_vars['ansible_host'])
            elif result._result.has_key('msg') and result._result.get('msg'):
                msg = "<font color='green'>ok: [{host}] => {stdout}</font>".format(host=result._host.get_name(), stdout=json.dumps(result._result, indent=4))
            else:
                msg = "<font color='green'>ok: [%s]</font>" % result._host.get_name()
        if result._task.loop and 'results' in result._result:
            self._process_items(result)
        else:
            self.logger.append(msg)

    def v2_runner_on_failed(self, result, *args, **kwargs):
        delegated_vars = result._result.get('_ansible_delegated_vars', None)
        self.task_failed[result._host.get_name()] = result._result
        if 'exception' in result._result:
            msg = result._result['exception'].strip().split('\n')[-1]
            # logger.error(msg=msg)
            del result._result['exception']
        if result._task.loop and 'results' in result._result:
            self._process_items(result)
        else:
            if delegated_vars:
                msg = "<font color='#DC143C'>fatal: [{host} -> {delegated_vars}]: FAILED! => {msg}</font>".format(
                    host=result._host.get_name(), delegated_vars=delegated_vars['ansible_host'], msg=json.dumps(result._result))
            else:
                msg = "<font color='#DC143C'>fatal: [{host}]: FAILED! => {msg}</font>".format(host=result._host.get_name(), msg=json.dumps(result._result))
            self.logger.append(msg)

    def v2_runner_on_unreachable(self, result):
        self.task_unreachable[result._host.get_name()] = result._result
        msg = "<font color='#DC143C'>fatal: [{host}]: UNREACHABLE! => {msg}</font>\n".format(host=result._host.get_name(), msg=json.dumps(result._result))
        self.logger.append(msg)

    def v2_runner_on_changed(self, result):
        self.task_changed[result._host.get_name()] = result._result
        msg = "<font color='yellow'>changed: [{host}]</font>\n".format(host=result._host.get_name())
        self.logger.append(msg)

    def v2_runner_on_skipped(self, result):
        self.task_skipped[result._host.get_name()] = result._result
        msg = "<font color='yellow'>skipped: [{host}]</font>\n".format(host=result._host.get_name())
        if result._task.loop and 'results' in result._result:
            self._process_items(result)
        else:
            self.logger.append(msg)

    def v2_runner_on_no_hosts(self, task):
        msg = "<font color='#DC143C'>skipping: no hosts matched</font>"
        self.logger.append(msg)

    def v2_playbook_item_on_skipped(self, result):
        msg = "<font color='yellow'>skipping: [%s] => (item=%s)</font>" % (result._host.get_name(), result._result['item'])
        self.logger.append(msg)

    def v2_playbook_on_play_start(self, play):
        name = play.get_name().strip()
        if not name:
            msg = u"<font color='#000000'>PLAY"
        else:
            msg = u"<font color='#000000'>PLAY [%s]" % name
        if len(msg) < 80:
            msg = msg + '*' * (79 - len(msg)) + '</font>'
        self.logger.append(msg)

    def _print_task_banner(self, task):
        msg = "<font color='#000000'>\nTASK [%s]" % (task.get_name().strip())
        if len(msg) < 80:
            msg = msg + '*' * (80 - len(msg)) + '</font>'
        self.logger.append(msg)

    def v2_playbook_on_task_start(self, task, is_conditional):
        self._print_task_banner(task)

    def v2_playbook_on_cleanup_task_start(self, task):
        msg = "<font color='#000000'>CLEANUP TASK [%s]</font>" % task.get_name().strip()
        self.logger.append(msg)

    def v2_playbook_on_handler_task_start(self, task):
        msg = "<font color='#000000'>RUNNING HANDLER [%s]</font>" % task.get_name().strip()
        self.logger.append(msg)

    def v2_playbook_on_stats(self, stats):
        msg = "<font color='#000000'>\nPLAY RECAP *********************************************************************</font>"
        self.logger.append(msg)
        hosts = sorted(stats.processed.keys())
        for h in hosts:
            t = stats.summarize(h)
            self.task_status[h] = {
                "ok": t['ok'],
                "changed": t['changed'],
                "unreachable": t['unreachable'],
                "skipped": t['skipped'],
                "failed": t['failures']
            }
            f_color, u_color, c_color, s_color, o_color, h_color = '#000000', '#000000', '#000000', '#000000', 'green', 'green'
            if t['failures'] > 0:
                f_color, h_color = '#DC143C', '#DC143C'
            elif t['unreachable'] > 0:
                u_color, h_color = '#DC143C', '#DC143C'
            elif t['changed'] > 0:
                c_color, h_color = 'yellow', 'yellow'
            elif t['ok'] > 0:
                o_color = 'green'
            elif t["skipped"] > 0:
                s_color = 'yellow'
            msg = """<font color='{h_color}'>{host}</font>\t\t: <font color='{o_color}'>ok={ok}</font>\t<font color='{c_color}'>changed={changed}</font>\t<font color='{u_color}'>unreachable={unreachable}</font>\t<font color='{s_color}'>skipped={skipped}</font>\t<font color='{f_color}'>failed={failed}</font>""".format(
                host=h, ok=t['ok'], changed=t['changed'],
                unreachable=t['unreachable'],
                skipped=t["skipped"], failed=t['failures'],
                f_color=f_color, h_color=h_color,
                u_color=u_color, c_color=c_color,
                o_color=o_color, s_color=s_color
            )
            self.logger.append(msg)

    def v2_runner_item_on_ok(self, result):
        delegated_vars = result._result.get('_ansible_delegated_vars', None)
        if result._task.action in ('include', 'include_role'):
            return
        elif result._result.get('changed', False):
            msg = "<font color='yellow'>changed"
        else:
            msg = "<font color='green'>ok"
        if delegated_vars:
            msg += ": [%s -> %s]" % (result._host.get_name(), delegated_vars['ansible_host'])
        else:
            msg += ": [%s]" % result._host.get_name()
        msg += " => (item=%s)</font>" % (json.dumps(self._get_item(result._result)))
        if (self._display.verbosity > 0 or '_ansible_verbose_always' in result._result) and not '_ansible_verbose_override' in result._result:
            msg += " => %s</font>" % json.dumps(result._result)
        self.logger.append(msg)

    def v2_runner_item_on_failed(self, result):
        delegated_vars = result._result.get('_ansible_delegated_vars', None)
        if 'exception' in result._result:
            msg = result._result['exception'].strip().split('\n')[-1]
            # logger.error(msg=msg)
            del result._result['exception']
        msg = "<font color='#DC143C'>failed: "
        if delegated_vars:
            msg += "[%s -> %s]</font>" % (result._host.get_name(), delegated_vars['ansible_host'])
        else:
            msg += "[%s] => (item=%s) => %s</font>" % (result._host.get_name(), result._result['item'], self._dump_results(result._result))
        self.logger.append(msg)

    def v2_runner_item_on_skipped(self, result):
        msg = "<font color='yellow'>skipping: [%s] => (item=%s)</font>" % (result._host.get_name(), self._get_item(result._result))
        if (self._display.verbosity > 0 or '_ansible_verbose_always' in result._result) and not '_ansible_verbose_override' in result._result:
            msg += " => %s</font>" % json.dumps(result._result)
        self.logger.append(msg)

    def v2_runner_retry(self, result):
        task_name = result.task_name or result._task
        msg = "<font color='#DC143C'>FAILED - RETRYING: %s (%d retries left).</font>" % (task_name, result._result['retries'] - result._result['attempts'])
        if (self._display.verbosity > 2 or '_ansible_verbose_always' in result._result) and not '_ansible_verbose_override' in result._result:
            msg += "Result was: %s</font>" % json.dumps(result._result, indent=4)
        self.logger.append(msg)
