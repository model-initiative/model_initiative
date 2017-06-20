This folder includes all decision stages / artificial observer and call scripts.
A decision stage takes a cell array where each cell is the output from a pathway model (i.e. a struct or vector).
The output should be the same as the experimental subject response (e.g. Target interval number. If it is equal to the input (1 interval only), use no_decision_stage.m