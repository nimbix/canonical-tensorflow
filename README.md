# Distributed Tensorflow Demo on IBM Power

## Turn-key Distributed Tensorflow Training

The best built-in abstraction in Tensorflow for running experiments (i.e., train/evaluation cycles) is `tf.contrib.learn`. The original API is inspired by the outstanding [scikit-learn](http://scikit-learn.org/stable/) project, but has evolved to support more powerful distributed training capabilities. Scikit-learn uses BLAS and high-performance local parallel solutions (it is built on top of numpy and scipy). However, it is not inherently well suited for multi-node, distributed training. Tensorflow provides the necessary mechanisms for arbitrarily placing variables and operations on any devices.

In practice, it is easier to use some sensible defaults in implementing distributed training pipelines. In `tf.contrib.learn`, the existing implementations of `Estimators` typically use between-graph replication as described by Derek Murray at the [TensorFlow Dev Summit 2017](https://www.youtube.com/watch?v=la_M6bCV91M).

The Estimators implemnet between-graph replication using a default device setter called `tf.train.replicated_device_setter`. This places variables on parameter servers using an online, round-robin bin packing algorithm and places operations on workers.

When the training pipeline is launched, each worker then starts and begins iterating on its partition of the data and transmits the variable updates back to the parameter servers. For more information on a design pattern whose implementations follow the between-graph replication pattern, have a look through the estimators code:
 * tensorflow/tensorflow/contrib/learn/python/learn/estimators/

## How to Leverage Distributed Tensorflow

For complete reference on how to implement an `Experiment,` refer to the [acual implementation in contrib.learn.experiment.py](https://github.com/tensorflow/tensorflow/blob/master/tensorflow/contrib/learn/python/learn/experiment.py).

Users can implement any training strategy that references `master`, `ps`, and `worker` process types. Each one of these has access to a single P100 GPU. The user's Python script will be executed in each environment, with the appropriate TF_CONFIG exported which does two things:
 1. Describes the configuration of the entire cluster by using a key-value store of `master`, `ps` and `worker` host/port addresses, and
 1. Identifies which task type and index the currently running process should assume.

More sophisticated training pipelines can be implemented in a similar manner, but this one should cover a good deal of use cases for between-graph replication.

### Minimal Experiment Example

```python

from tensorflow.contrib.learn.python.learn.estimators import test_data
from tensorflow.contrib.learn.python.learn import experiment
from tensorflow.contrib.learn.python.learn import RunConfig
from tensorflow.contrib.layers.python.layers import feature_column
from tensorflow.contrib.learn.python.learn.estimators import dnn
import learn_runner
import os


def get_experiment(output_dir):
    """Run a simple Experiment. Cluster config can be set in the environment"""
    # Get the TF_CONFIG from the environment, and set some other options.
    # This is optional since the default RunConfig() for Estimators will
    # pick up the cluster configuration from TF_CONFIG environment
    config = RunConfig(log_device_placement=True)
    exp = experiment.Experiment(
        estimator=dnn.DNNRegressor(
            feature_columns=[
                feature_column.real_valued_column(
                    'feature', dimension=4)
            ],
            model_dir=output_dir,
            hidden_units=[3, 3],
            config=config
        ),
        train_input_fn=test_data.iris_input_logistic_fn,
        eval_input_fn=test_data.iris_input_logistic_fn,
        train_steps=1000)
    return exp


def main():
  """Users should import learn_runner and run it"""
  if 'EXPERIMENT_ID' in os.environ:
    experiment_dir = os.environ['EXPERIMENT_ID']
  else:
    experiment_dir = os.environ['JOB_NAME']
  output_dir = '/data/tensorflow-output/%s' % (experiment_dir)
  learn_runner.run(
        experiment_fn=get_experiment,
        output_dir=output_dir)


if __name__ == '__main__':
  main()
```

The job environment will automatically run at least three processes on the master node:
 * master (index 0)
 * ps (index 0)
 * worker (index 0)
 * worker (index 1)

For slave nodes, it will launch 4 workers per node (one per GPU), with the index ID increasing per worker.

The IBM Power Minksy machines are equipped with 4 x P100s. TF_CONFIG will be exported and the appropriate processes will be started to support scaling with one parameter server for every machine and one worker for each GPU, beyond the initial 3 processes.

Tensorboard runs from /data/tensorflow-output/ and each session runs with the current JOB_NAME (or EXPERIMENT_ID). Inputing a previously used EXPERIMENT_ID will check the /data/tensflow-output directory for previous runs and resume if there are any existing checkpoints.

Reference:
 * https://www.tensorflow.org/versions/r0.12/tutorials/estimators/
 * [Distributed TensorFlow @ TensorFlow Dev Summit 2017](https://www.youtube.com/watch?v=la_M6bCV91M)
