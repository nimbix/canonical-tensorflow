# Distributed Tensorflow Demo on IBM Power

## Turn-key Distributed Tensorflow Training

The best built-in abstraction in Tensorflow for running experiments (i.e., train/evaluation cycles) is `tf.contrib.learn`. The original API is inspired by the outstanding [scikit-learn](http://scikit-learn.org/stable/) project.

Tensorflow has much more powerful distributed training capabilities than scikit-learn. Scikit-learn uses BLAS and high-performance local parallel solutions (it is built on top of numpy and scipy). However, it is not inherently well suited for multi-node, distributed training.

Even with existing mature libraries such as OpenMPI, MVAPICH2, Intel MPI, IBM MPI (formerly known as Platform Computing MPI) in the ecosystem, there have been very few distributed machine learning frameworks released. Implementing distributed algorithms, it turns out, is quite hard.

Tensorflow provides a different programming model for distributed computation. In neural networks, there are two common architectures for distributed training: syncrhonous training, and asynchronous training.


tensorflow/tensorflow/contrib/learn/python/learn/estimators/


### Synchronous Training
Synchronous training assumes that each parallel branch of the computation graph runs for approximately the same amount of time. This is hard assumption to make if you do not have enough of the same kind of hardware! In an ad-hoc cluster computing environment (an office of desktops, a hand-built cluster, or a cloud that doesn't specialize in high performance computing), variation among computational nodes can vary greatly, causing the performance of the computational branches to be as good as the slowest unit.

### Asynchronous Training
Asynchronous training, however, allows parallel branches of the computation graph to run asynchronously, updating parameters (i.e., the iterative resulting parameters of an optimizater, such as stochastic gradient descent).  This presents a potentially greater challenge, because updates on the slowest branch might be repeating unnecessary computation.

What are the trade offs between these two architectures?

What does this mean for applied machine learning specialists? It means that implementing distributed algorithms is actually quite hard. There are a lot of tradeoffs, and optimizing these algorithms for performance and scale is a fundamentally different skillset than solving data science problems on massive data sets.

Because of the complexities of distributed training, Tensorflow Learn has implemented abstractions that make it simpler to run distributed, and Nimbix, partnering with Canonical, has developed a turn-key environment where training workflows can be run without any expertise in the infrastructure itself.


## How to Leveraged Distributed Tensorflow

The easiest way to leverage Distributed Tensorflow is to create an experiment using `tf.contrib.learn.Experiment`. The documentation on this is a bit sparse, so we will walk through step-by-step how to run an Experiment using Distributed Tensorflow! Judging from the comments about "internal" code and the number of recent git commits, this is one of the main ways that Google runs experiments internally (Google employees: we're glad to hear your comments on this!).

For complete reference, refer to the [acual implementation in contrib.learn.experiment.py](https://github.com/tensorflow/tensorflow/blob/master/tensorflow/contrib/learn/python/learn/experiment.py).

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
from tensorflow.contrib.learn import learn_runner

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

    learn_runner.run(
      experiment_fn=_create_my_experiment,
      output_dir="some/output/dir",
      schedule="train")

```

Reference:
 * https://www.tensorflow.org/versions/r0.12/tutorials/estimators/
