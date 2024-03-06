#include <iostream>
#include <set>
#include <vector>
#include "parser.hpp"

extern int yylex();
extern Node *root; 


int main(int argc, char** argv) {

  if (!yylex()) {

    std::cout << "digraph G {" << std::endl;

    print_tree_recursively(root, "n0", 0);
    
    std::cout << "}" << std::endl;
  }
}
