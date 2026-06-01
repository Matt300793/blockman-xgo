import os

DEBUG = True # Turns on debugging features in Flask

CUR_DIR = os.path.abspath(os.path.dirname(__file__))

# production
AWS_REGION = "us-east-1"
DEPLOY_DIR = "/home/console/webservice/web-portal/playbook"
SERVICE_CONFIG = DEPLOY_DIR + "/config-oversea.yaml"
TINYDB_DIR = os.path.join(CUR_DIR, 'data')
DATA_DIR = TINYDB_DIR
SQLALCHEMY_DATABASE_URI = 'sqlite:///database.db'
SQLALCHEMY_TRACK_MODIFICATIONS = True

# local dev
# AWS_REGION = "cn-northwest-1"
# DEPLOY_DIR = "/mnt/d/reps/pickaxe/scripts/web/web-portal/playbook"
# SERVICE_CONFIG = DEPLOY_DIR + "/config.yaml"
# TINYDB_DIR = os.path.join(CUR_DIR, 'data')
# DATA_DIR = TINYDB_DIR
# SQLALCHEMY_DATABASE_URI = 'sqlite:///database.db'
# SQLALCHEMY_TRACK_MODIFICATIONS = True

# ningxia dev
# AWS_REGION = "cn-northwest-1"
# DEPLOY_DIR = "/home/console/webservice-dev/web-portal/playbook"
# SERVICE_CONFIG = DEPLOY_DIR + "/config-dev.yaml"
# TINYDB_DIR = os.path.join(CUR_DIR, 'data')
# DATA_DIR = TINYDB_DIR
# SQLALCHEMY_DATABASE_URI = 'sqlite:///database.db'
# SQLALCHEMY_TRACK_MODIFICATIONS = True
