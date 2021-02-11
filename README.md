# turing-machine-idris

My exercise in Idris, implementing turing machine.

## Build

`$ idris --build tm.ipkg` to create an executable named `tm`.

## Execution

`$ ./tm program.tm --tape=0001 --max-steps=1000`

First argument is the file path of the executed program.

`--tape` is the initial tape (from 0th position to right). This is optional.

`--max-steps` is the maximum number of steps executed. This is optional and the default is infinity (which may hang).

## Example

```
$ ./tm example/irrational.tm --max-steps=127
...1010010001000010001011...
                        ↑
                        8
```
