# Distributed Tensorflow Demo on IBM Power

## Turn-key Distributed Tensorflow Training

The best built-in abstraction in Tensorflow for running experiments (i.e., train/evaluation cycles) is `tf.contrib.learn`. The original API is inspired by the outstanding [scikit-learn](http://scikit-learn.org/stable/) project, but has evolved to support more powerful distributed training capabilities. Scikit-learn uses BLAS and high-performance local parallel solutions (it is built on top of numpy and scipy). However, it is not inherently well suited for multi-node, distributed training. Tensorflow provides the necessary mechanisms for arbitrarily placing variables and operations on any devices.

In practice, it is easier to use some sensible defaults in implementing distributed training pipelines. In `tf.contrib.learn`, the existing implementations of `Estimators` typically use between-graph replication as described by Derek Murray at the [TensorFlow Dev Summit 2017](https://www.youtube.com/watch?v=la_M6bCV91M).

The Estimators implemnet between-graph replication using a default device setter called `tf.train.replicated_device_setter`. This places variables on parameter servers using an online, round-robin bin packing algorithm and places operations on workers.

When the training pipeline is launched, each worker then starts and begins iterating on its partition of the data and transmits the variable updates back to the parameter servers. For more information on a design pattern whose implementations follow the between-graph replication pattern, have a look through the estimators code:
 * tensorflow/tensorflow/contrib/learn/python/learn/estimators/

## How to Leverage Distributed Tensorflow

Nimbix and Canonical have teamed up to implement a turn-key environment to leverage Distributed Tensorflow. For complete reference, refer to the [acual implementation in contrib.learn.experiment.py](https://github.com/tensorflow/tensorflow/blob/master/tensorflow/contrib/learn/python/learn/experiment.py).

```python
class Experiment(object):
  """Experiment is a class containing all information needed to train a model.

  After an experiment is created (by passing an Estimator and inputs for
  training and evaluation), an Experiment instance knows how to invoke training
  and eval loops in a sensible fashion for distributed training.
  """
```

### Minimal Experiment Example

```python
from tensorflow.contrib.learn.python.learn.estimators import test_data
from tensorflow.contrib.learn.python.learn import experiment
from tensorflow.contrib.layers.python.layers import feature_column
import learn_runne

def run_experiment():
    exp = experiment.Experiment(
        estimator=dnn.DNNRegressor(
            feature_columns=[
                feature_column.real_valued_column(
                    'feature', dimension=4)
            ],
            hidden_units=[3, 3]),
        train_input_fn=test_data.iris_input_logistic_fn,
        eval_input_fn=test_data.iris_input_logistic_fn)
    exp.test()

def _create_my_experiment(output_dir):
    return tf.contrib.learn.Experiment(
      estimator=my_estimator(model_dir=output_dir),
      train_input_fn=my_train_input,
      eval_input_fn=my_eval_input)

def main():
  learn_runner.run(
      experiment_fn=_create_my_experiment,
      # Write the models to distributed filesystem
      output_dir="/data/tensorflow-output",
      # Can be: train, serve, train_and_evaluate, or blank
      schedule="train_and_evaluate")

if __name__ == '__main__':
   main()

```

The job environment will automatically run at least three processes on the master node:
 * master (index 0)
 * ps (index 0)
 * worker (index 0)
 * worker (index 1)

The IBM Power Minksy machines are equipped with 4 x P100s. TF_CONFIG will be exported and the appropriate processes will be started to support scaling with one parameter server for every machine and one worker for each GPU, beyond the initial 3 processes.

Tensorboard runs from /data/tensorflow-output/ and each session runs with the current JOB_NAME.

Reference:
 * https://www.tensorflow.org/versions/r0.12/tutorials/estimators/
 * [Distributed TensorFlow @ TensorFlow Dev Summit 2017](https://www.youtube.com/watch?v=la_M6bCV91M)
