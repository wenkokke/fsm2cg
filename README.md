# FSM to CG3

This is a small project which reads finite state machines, and
produces valid grammars for vislcg3 which accept only strings accepted
by the finite state machine.

For instance, take the grammar `a*bc*`. We can write this grammar down
in the format used by `fsm2cg` as follows:

```
0
0 a 0
0 b 1
1 c 1
1
```

The first line contains the start state. The lines after that describe
transitions---with numbers always used for states, and any string in
between those numbers representing the words. The last line lists the
accepting states---separated by spaces.

Feeding this finite state machine to `fsm2cg` will result in the
following grammar:

``` python
DELIMITERS = "<$.>" "<$?>" "<$!>" "<$:>" "<$\;>" ;

SET <<< = (<<<);
SET >>> = (>>>);
SET S0 = (s0);
SET S1 = (s1);
SET A = ("a");
SET B = ("b");
SET C = ("c");
SET FINAL = (s1);

BEFORE-SECTIONS
ADD S0 A IF (-1 >>>);
ADD S0 A IF (-1 S0);
ADD S1 B IF (-1 S0);
ADD S1 C IF (-1 S1);

AFTER-SECTIONS
REMCOHORT (*) IF (1* <<< LINK NOT 0 FINAL);
REMCOHORT <<< (NOT 0 FINAL);
```

This will either accept the string (and leave all cohorts and readings
untouched) or remove all cohorts. Note that this will accept a string
even if there is a single valid reading---though it should not be hard
to implement a variant which trims invalid readings based on the
finite state machine.
