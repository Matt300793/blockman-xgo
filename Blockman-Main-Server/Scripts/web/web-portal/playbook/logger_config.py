#!/usr/bin/env python
# encoding: utf-8

import logging
import os
from logging.handlers import RotatingFileHandler
import coloredlogs

LEVELS = {'NOSET': logging.NOTSET,
          'DEBUG': logging.DEBUG,
          'INFO': logging.INFO,
          'WARNING': logging.WARNING,
          'ERROR': logging.ERROR,
          'CRITICAL': logging.CRITICAL}


def config_logging(file_name="log.txt", log_level="INFO"):
    '''
    @summary: config logging to write logs to local file
    @param file_name: name of log file
    @param log_level: log level
    '''
    # clear old root logger handlers
    logging.getLogger("").handlers = []

    logs_dir = os.path.join(os.path.dirname(__file__), "logs")
    if not os.path.isdir(file_name):
        file_dir = os.path.dirname(file_name)
        if file_dir and len(file_dir.strip()) > 0:
            logs_dir = file_dir
    if os.path.exists(logs_dir) and os.path.isdir(logs_dir):
        pass
    else:
        print logs_dir
        os.makedirs(logs_dir)

    file_name = os.path.join(logs_dir, file_name)
    # define a rotating file handler
    rotatingFileHandler = logging.handlers.RotatingFileHandler(filename=file_name,
                                                               maxBytes=1024 * 1024 * 50,
                                                               backupCount=5)
    formatter = logging.Formatter("%(asctime)s %(name)-12s %(levelname)-8s %(message)s")
    rotatingFileHandler.setFormatter(formatter)
    logging.getLogger("").addHandler(rotatingFileHandler)

    # define a handler whitch writes messages to sys
    console = logging.StreamHandler()
    # set a format which is simple for console use
    formatter = logging.Formatter("%(message)s")
    # tell the handler to use this format
    console.setFormatter(formatter)
    # add the handler to the root logger
    logging.getLogger("").addHandler(console)
    # set initial log level
    logger = logging.getLogger("")
    level = LEVELS[log_level.upper()]
    logger.setLevel(level)
