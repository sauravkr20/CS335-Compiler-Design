#include <iostream>
#include <algorithm>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <vector>

#include "ast.h"


Node* create_node(const std::string& label, const std::vector<Node*>& children, const std::string& category) {
    return new Node(label, children, category);
}

void print_tree_recursively(Node *n, std::string prefix, int lineno) {
  if (n != NULL && (*n).label == "Block") {
    std::cout << "  " << prefix << " [label=\"Block\"];" << std::endl;
    for (Node *child: (*n).children) {
      std::cout << "  " << prefix << " -> ";
      std::string next_prefix = prefix + "_" + std::to_string(lineno);
      print_tree_recursively(child, next_prefix, lineno);
      lineno++;
    }
  }

  if (n != NULL && !(*n).category.empty()) {
    std::string cat = (*n).category;
    if (cat == "Identifier" ) {
      std::cout << prefix << ";" << std::endl;
      std::cout << "  " << prefix << " [label=\"Id -> " << (*n).label << "\"];" << std::endl;
    }
    else if (cat == "Float") {
      std::cout << prefix << ";" << std::endl;
      std::cout << "  " << prefix << " [label=\"Float -> " << std::noshowpoint << std::stof((*n).label) << "\"];" << std::endl;
    }
    else if (cat == "Integer") {
      std::cout << prefix << ";" << std::endl;
      std::cout << "  " << prefix << " [label=\"Int -> " << (*n).label << "\"];" << std::endl;
    }
    else if (cat == "Boolean") {
      std::cout << prefix << ";" << std::endl;
      std::cout << "  " << prefix << " [label=\"Bool -> " << (*n).label << "\"];" << std::endl;
    }
    else if (cat == "Break") {
      std::cout << prefix << ";" << std::endl;
      std::cout << "  " << prefix << " [label=\"Break_stmt\"];" << std::endl;
    }
    else if (cat == "If") {
      std::cout << prefix << ";" << std::endl;
      std::cout << "  " << prefix << " [label=\"If_stmt\"];" << std::endl;
      int num = 0;
      for (Node *child: (*n).children) {
        if (num == 0) {
          std::cout << "  " << prefix << " -> ";
          print_tree_recursively(child, prefix + "_cond", lineno);
          num++;
        }
        else if (num == 1) {
          std::cout << "  " << prefix << " -> " << prefix << "_if;" << std::endl;
          print_tree_recursively(child, prefix + "_if", 0);
          num++;
        }
        else {
          if (child != NULL) {
            std::cout << "  " << prefix << " -> " << prefix << "_else;" << std::endl;
            print_tree_recursively(child, prefix + "_else", 0);
          }
        }
      }
    }
    else if (cat == "While") {
      std::cout << prefix << ";" << std::endl;
      std::cout << "  " << prefix << " [label=\"while_loop\"];" << std::endl;
      int num = 0;
      for (Node *child: (*n).children) {
        if (num == 0) {
          std::cout << "  " << prefix << " -> ";
          print_tree_recursively(child, prefix + "_cond", lineno);
          num++;
        }
        else if (num == 1) {
          std::cout << "  " << prefix << " -> " << prefix << "_while;" << std::endl;
          print_tree_recursively(child, prefix + "_while", 0);
          num++;
        }
      }
    }
    else if (cat == "Expression") {
      std::cout << prefix << ";" << std::endl;
      std::cout << "  " << prefix << " [label=\"" << (*n).label << "\"];" << std::endl;
      int num = 0;
      for (Node *child: (*n).children) {
        std::cout << "  " << prefix << " -> ";
        if (num == 0) {
          print_tree_recursively(child, prefix + "_lhs", lineno);
          num++;
        }
        else {
          print_tree_recursively(child, prefix + "_rhs", lineno);
        }
      }
    }
    else if (cat == "Assignment") {
      std::cout << prefix << ";" << std::endl;
      std::cout << "  " << prefix << " [label=\"stmt\"];" << std::endl;
      int num = 0;
      for (Node *child: (*n).children) {
        std::cout << "  " << prefix << " -> ";
        if (num == 0) {
          print_tree_recursively(child, prefix + "_lhs", lineno);
          num++;
        }
        else {
          print_tree_recursively(child, prefix + "_rhs", lineno);
        }
      }
    }
  }
}