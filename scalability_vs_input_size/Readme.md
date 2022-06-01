## Scalability of Binsec/Rel in relation to input message size

This folder studies the scalability of Binsec/Rel in relation to the input
message size. We report on the performance of Binsec/Rel for various input
message size.


### Run experiments
These additional experiments are done on a subset of the cryptographic programs
used for [general scalability experiments](../src/).

Programs can be found under the [src](./src/) directory and contain a script
`expes.py` to run the corresponding experiments.

### Process the results
Scripts to process the results can be found under the
[python_scripts](./python_scripts/) directory. The main script
[stats.py](./python_scripts/stats.py) gives detail on indidual test cases and
reproduces tables found in the paper.
