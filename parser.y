%{
#include <iostream>
#include <vector>
#include "parser.hpp"

extern int yylex();
void yyerror(YYLTYPE* loc, const char* err);
std::string translate_boolean_str(std::string* boolean_str);

Node *root = create_node("Block");
%}

/* Enable location tracking. */
%locations
%code requires {
#include "ast.h"
}

%union {
  std::string* str;
  Node* node;
  std::vector<Node*> *collection;
}

%define api.pure full
%define api.push-pull push
%define parse.error verbose

%token<str> IDENTIFIER FLOAT INTEGER BOOLEAN

%token<node> INDENT DEDENT NEWLINE
%token<node> AND BREAK CONTINUE DEF ELIF ELSE FOR IF NOT OR RETURN WHILE
%token<node> ASSIGN PLUS MINUS MUL DIV
%token<node> EQ NEQ GT GTE LT LTE
%token<node> LPAREN RPAREN COMMA COLON

%type<collection> stmts
%type<node> stmt expression negated_expression primary_expression assign_stmt
%type<node> if_stmt condition else_block elif_blocks block
%type<node> while_stmt break_stmt continue_stmt 

%left OR
%left AND
%left PLUS MINUS
%left MUL DIV
%left EQ NEQ GT GTE LT LTE
%right NOT

%start python_code

%%

python_code
  : stmts { root->children = *$1; }
  ;

stmts
  : stmt {
     $$ = new std::vector<Node*>;
     $$->push_back($1);
    }
  | stmts stmt {
      $1->push_back($2);
      $$ = $1;
    }
  ;

stmt
  : assign_stmt { $$ = $1; }
  | if_stmt { $$ = $1; }
  | while_stmt { $$ = $1; }
  | break_stmt { $$ = $1; }
  | continue_stmt { $$ = $1; }
  ;

primary_expression
  : IDENTIFIER {
      $$ = create_node(*$1, {}, "Identifier");
    }
  | FLOAT {
      $$ = create_node(*$1, {}, "Float");
    }
  | INTEGER {
      $$ = create_node(*$1, {}, "Integer");
    }
  | BOOLEAN {
      std::string booleanValue = *$1;
      $$ = create_node((booleanValue == "True") ? booleanValue : "0", {}, "Boolean");
    }
  | LPAREN expression RPAREN { $$ = $2; }
  ;

negated_expression: NOT primary_expression { };

expression
  : primary_expression { $$ = $1; }
  | negated_expression { $$ = $1; }
  | expression PLUS expression {
      $$ = create_node("PLUS", {$1, $3}, "Expression");
    }
  | expression MINUS expression {
      $$ = create_node("MINUS", {$1, $3}, "Expression");
    }
  | expression MUL expression {
      $$ = create_node("MUL", {$1, $3}, "Expression");
  }
  | expression DIV expression {
      $$ = create_node("DIV", {$1, $3}, "Expression");
  }
  | expression EQ expression {
      $$ = create_node("EQ", {$1, $3}, "Expression");
    }
  | expression NEQ expression {
      $$ = create_node("NEQ", {$1, $3}, "Expression");
    }
  | expression GT expression {
      $$ = create_node("GT", {$1, $3}, "Expression");
    }
  | expression GTE expression {
      $$ = create_node("GTE", {$1, $3}, "Expression");
    }
  | expression LT expression {
      $$ = create_node("LT", {$1, $3}, "Expression");
    }
  | expression LTE expression {
      $$ = create_node("LTE", {$1, $3}, "Expression");
    }
  ;

assign_stmt
  : IDENTIFIER ASSIGN expression NEWLINE {
      $$ = create_node("Assignment", {create_node(*$1, {}, "Identifier"), $3}, "Assignment");
    }
  ;

block
  : INDENT stmts DEDENT {
    $$ = create_node("Block", *$2);
    }
  ;

condition
  : expression { $$ = $1; }
  | condition AND condition {
      $$ = create_node("AND", {$1, $3}, "Condition");
    }
  | condition OR condition {
      $$ = create_node("OR", {$1, $3}, "Condition");
    }
  ;

if_stmt
  : IF condition COLON NEWLINE block elif_blocks else_block {
    $$ = create_node("If", {$2, $5, $6, $7}, "If");
  }
  ;

elif_blocks
  : %empty {
    $$ = NULL;
  }
  | elif_blocks ELIF condition COLON NEWLINE block {
    $$ = create_node("Block", {$3, $6}, "Elif");
  }
  ;

else_block
  : %empty {
    $$ = NULL;
    }
  | ELSE COLON NEWLINE block {
    $$ = $4;
    };

while_stmt
  : WHILE condition COLON NEWLINE block {
      $$ = create_node("While", {$2, $5}, "While");
    }
  ;

break_stmt
  : BREAK NEWLINE {
    $$ = create_node("Break", {}, "Break");
    }
  ;

continue_stmt
  : CONTINUE NEWLINE {
    $$ = create_node("Continue", {}, "Continue");
    }
  ;

%%

void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error (line " << loc->first_line << "): " << err << std::endl;
}
