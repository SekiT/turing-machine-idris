# turing-machine-idris

My exercise in Idris, implementing turing machine.

## Build

`$ idris --build tm.ipkg` to create an executable named `tm`.

## Execution

`$ ./tm program.tm 0001 300`

The first argument is the file path of the executed program.

The second argument is the initial tape (from 0th position to right). Undefined positions are filled with 0.

The third argument is the maximum number of steps executed. This is optional and the default is infinity (which may hang).

## Example

```
$ ./tm example/irrational.tm 0 127
...1010010001000010001011...
                        ↑
                        8
```
