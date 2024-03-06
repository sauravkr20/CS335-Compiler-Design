#ifndef AST_H
#define AST_H

#include <vector>
#include <string>

struct Node {
    std::string label;
    std::vector<Node*> children;
    std::string category;  // Added for category information

    Node(const std::string& label, const std::vector<Node*>& children = {}, const std::string& category = "")
        : label(label), children(children), category(category) {}
};

void print_tree_recursively(Node *n, std::string, int);

Node* create_node(const std::string& label, const std::vector<Node*>& children = {}, const std::string& category = "");

#endif  // AST_H