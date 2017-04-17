import json
import os

def get_nodes():
  with open('/etc/JARVICE/nodes', 'rb') as f:
    nodes = f.readlines()
  return map(lambda x: x.strip(), nodes)

def gen_config(nodes, worker_ports):
  """Configuration with one parameter per node and one per GPU (four per node on the Minsky's)

  The master is located on the head node.
  """
  ps_hosts = map(lambda x: '%s:%s' % (x, 2222), nodes)
  worker_hosts = []
  master = '%s:2224' % (nodes[0])
  for i in nodes:
    for j in worker_ports:
      host = '%s:%s' % (i, j)
      worker_hosts.append(host)
  tf_config = {
    'cluster': {
      'ps': ps_hosts,
      'worker': worker_hosts,
      'master': [master,]
    },
    'task': {
        'type': os.environ['TASK_TYPE'],
        'index': os.environ['TASK_ID']
    },
    'environment': 'cloud'
  }
  return tf_config

def validate_task_type():
  TASK_TYPES = ['ps', 'master', 'worker']
  if os.environ['TASK_TYPE'] not in TASK_TYPES:
    raise 'TASK_TYPE must be one of %s' % (', '.join(TASK_TYPES))
	
if __name__ == '__main__':
  if 'TASK_TYPE' not in os.environ:
    raise 'TASK_TYPE is not defined in environment'
  print json.dumps(gen_config(get_nodes(), ['2223'])) #, '2224', '2225', '2226']))

