INPUT_FILE := ./testCases/p1.simple.py

all: parse

parser.cpp parser.hpp: parser.y
	bison -d -o parser.cpp parser.y

scanner.cpp: scanner.l
	flex -o scanner.cpp scanner.l

parse: main.cpp parser.cpp scanner.cpp ast.cpp
	g++ main.cpp parser.cpp scanner.cpp ast.cpp -o parse -std=c++11

clean:
	rm -f parse scanner.cpp parser.cpp parser.hpp *.gv
	rm -f output.pdf

run:
	./parse < $(INPUT_FILE) > output.gv
	dot -Tpdf -o output.pdf output.gv

	
