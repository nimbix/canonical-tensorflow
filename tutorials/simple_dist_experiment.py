from tensorflow.contrib.learn.python.learn.estimators import test_data
from tensorflow.contrib.learn.python.learn import experiment
from tensorflow.contrib.learn.python.learn import RunConfig
from tensorflow.contrib.layers.python.layers import feature_column
from tensorflow.contrib.learn.python.learn.estimators import dnn
import learn_runner
import argparse

def get_experiment(output_dir):
    """Run a simple Experiment. Cluster config can be set in the environment"""
    # Get the TF_CONFIG from the environment, and set some other options.
    # This is optional since the default RunConfig() for Estimators will
    # pick up the cluster configuration from TF_CONFIG environment
    config = RunConfig(log_device_placement=True, cores=1)
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
        train_steps=500000)
    return exp

if __name__ == '__main__':
  parser = argparse.ArgumentParser()
  parser.add_argument("schedule")
  args = parser.parse_args()

  learn_runner.run(
	experiment_fn=get_experiment,
	output_dir="/data/experiment-model",
      	schedule=args.schedule)
