import json
import os
import sys

MASTER_PORT = '2221'
PS_PORT = '2222'
WORKER_PORTS = ['2223', '2224', '2225', '2226']


def get_nodes():
  """Reads the nodes from the environment"""
  with open('/etc/JARVICE/nodes', 'rb') as f:
    nodes = f.readlines()
  return map(lambda x: x.strip(), nodes)


def gen_config(nodes, worker_ports):
  """Configuration with one parameter per node and one per GPU (four per node on the Minsky's)

  The master is located on the head node.
  """
  # Make the assumption that there are 4 GPUs per node
  # The configuration will be the following:
  #  Node 1: master (gpu0), ps (gpu1), worker0 (gpu2), worker1 (gpu3)
  #  Node 2: worker{4*(NODE+1)-2 + {0..3}}

  worker_hosts = []
  ps_hosts = []
  master_hosts = []

  for idx, host in enumerate(nodes):
    if idx == 0:
      for port in WORKER_PORTS[0:2]:
        worker_hosts.append('%s:%s' % (host, port))
      ps_hosts.append('%s:%s' % (host, PS_PORT))
      master_hosts.append('%s:%s' % (host, MASTER_PORT))
    else:
      for port in WORKER_PORTS:
        worker_hosts.append('%s:%s' % (host, port))
  if os.environ['TASK_TYPE'] == 'worker':
    task_index = int(os.environ['TASK_ID']) - 2
  else:
    task_index = int(os.environ['TASK_ID'])
  tf_config = {
    'cluster': {
      'ps': ps_hosts,
      'worker': worker_hosts,
      'master': master_hosts
    },
    'task': {
        'type': os.environ['TASK_TYPE'],
        'index': task_index
    },
    'environment': 'cloud'
  }
  return tf_config


def validate_task_type():
  TASK_TYPES = ['ps', 'master', 'worker']

  if os.environ['TASK_TYPE'] not in TASK_TYPES:
    print 'TASK_TYPE must be one of %s' % (', '.join(TASK_TYPES))
    sys.exit(1) 

  if not 'TASK_ID' in os.environ:
    print'TASK_ID must be defined as an integer'
    sys.exit(1)

if __name__ == '__main__':

  if 'TASK_TYPE' not in os.environ:
    raise 'TASK_TYPE is not defined in environment'
    sys.exit(1)

  validate_task_type()

  print json.dumps(gen_config(get_nodes(), WORKER_PORTS))
