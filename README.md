## Running benchmarks

The main benchmarks in this code can be run using the `run_benchmark.sh` script. At the moment we mainly have one `main.nr` file, which includes the various functions we'd like to test. You'd need to uncomment the  `main()` function in `main.nr` that tests the specific function you'd like to test. We'll update this code to take the specific function as an argument and deal with all that.

Note that the `run_benchmark.sh` script contains parameters `LOW_LOG_STR_SIZE` and `HIGH_LOG_STR_SIZE`, which can be toggled to get benchmarks for different sized strings.

## Example workloads

### Ethereum DID resolver

The example provided by uport of a DID doc, [here](https://developer.uport.me/ethr-did-resolver/readme) shows a minimal DID doc for a user who has no transactions. It is a JSON with 522 characters.

