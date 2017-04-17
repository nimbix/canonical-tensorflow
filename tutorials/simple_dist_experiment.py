from tensorflow.contrib.learn.python.learn.estimators import test_data
from tensorflow.contrib.learn.python.learn import experiment
from tensorflow.contrib.layers.python.layers import feature_column
from tensorflow.contrib.learn.python.learn.estimators import dnn
import learn_runner
import argparse

def get_experiment(output_dir):
    """Run a simple Experiment. Cluster config can be set in the environment"""
    exp = experiment.Experiment(
        estimator=dnn.DNNRegressor(
            feature_columns=[
                feature_column.real_valued_column(
                    'feature', dimension=4)
            ],
            model_dir=output_dir,
            hidden_units=[3, 3]),
        train_input_fn=test_data.iris_input_logistic_fn,
        eval_input_fn=test_data.iris_input_logistic_fn,
        train_steps=50000)
    return exp

if __name__ == '__main__':
  parser = argparse.ArgumentParser()
  parser.add_argument("schedule")
  args = parser.parse_args()

  learn_runner.run(
	experiment_fn=get_experiment,
	output_dir="/data/experiment-model",
      	schedule=args.schedule)
