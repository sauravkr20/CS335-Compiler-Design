# CS335-Compiler-Design

## Group Members: 
* Aryan Bansal : 200198
* Dikshant Raj Meena: 180247
* Saurav Kumar: 200906

## Tools Used: 
* GraphViz
* flex
* bison

## Implementation
The following syntatic structures are supported:

* Assignments
* Arithmetic
* If stmts
* While loops
* Break stmts
* Continue stmts
* Function stmts

## Using

put the path of file to be generated AST for in the Makefile  INPUT_FILE  :
like 
```
INPUT_FILE = ./test.py
```
post this run the following commands

```
cd src
make
make run
```
this will create a output.pdf file , which contains the AST of the the code input
