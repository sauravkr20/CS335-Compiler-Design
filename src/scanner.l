/*
 * Lexer definition for simplified Python syntax.
 */

%{
#include <iostream>
#include <stack>
#include <cstdlib>

#include "parser.hpp"


std::stack<int> _indent_stack;
%}

%option noyywrap
%option yylineno

%%

%{
  if (_indent_stack.empty()) {
    _indent_stack.push(0);
  }


  yypstate* pstate = yypstate_new();

  YYSTYPE yylval;
  YYLTYPE loc;
%}

^[ \t]*\r?\n   { /* Skip blank lines */ }

^[ \t]*#.*\r?\n    { /* Skip whole-line comments. */ }

#.*$        { /* Skip comments on the same line as a stmt. */ }

^[ \t]+     {
              
              if (_indent_stack.top() < yyleng) {

                _indent_stack.push(yyleng);                    
                yylval.str = NULL ? new std::string(NULL) : NULL;            
                loc.first_line = loc.last_line = yylineno;               
                int status = yypush_parse(pstate, INDENT, &yylval, &loc); 
                if (status != YYPUSH_MORE) {                             
                  yypstate_delete(pstate);                               
                  return status;                                         
                }                                                        
                
                
              } else {

                while (!_indent_stack.empty() && _indent_stack.top() != yyleng) {
                  _indent_stack.pop();              
                  yylval.str = NULL ? new std::string(NULL) : NULL;            
                  loc.first_line = loc.last_line = yylineno;               
                  int status = yypush_parse(pstate, DEDENT, &yylval, &loc); 
                  if (status != YYPUSH_MORE) {                             
                    yypstate_delete(pstate);                               
                    return status;                                         
                  }             
                }

                
                if (_indent_stack.empty()) {
                  std::cerr << "Error: Incorrect indentation on line "
                    << yylineno << std::endl;
                  return 1;
                }
              }
            }

^[^ \t\n]+  {
             
              while(_indent_stack.top() != 0) {
                _indent_stack.pop();     
                yylval.str = NULL;            
                loc.first_line = loc.last_line = yylineno;               
                int status = yypush_parse(pstate, DEDENT, &yylval, &loc); 
                if (status != YYPUSH_MORE) {                             
                  yypstate_delete(pstate);                               
                  return status;                                         
                }          
              }
              REJECT;
            }

\r?\n       {                      
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, NEWLINE, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }        
            }

<<EOF>>     {
              /*
               * If we reach the end of the file, pop all indentation levels
               * off the stack, and emit a DEDENT for each one.
               */
              while(_indent_stack.top() != 0) {
                _indent_stack.pop();
                              
                yylval.str = NULL;            
                loc.first_line = loc.last_line = yylineno;               
                int status = yypush_parse(pstate, DEDENT, &yylval, &loc); 
                if (status != YYPUSH_MORE) {                             
                  yypstate_delete(pstate);                               
                  return status;                                         
                }  
              }
              int status = yypush_parse(pstate, 0, NULL, NULL);
              yypstate_delete(pstate);
              return status;
            }

[ \t]       { /* Ignore spaces that haven't been handled above. */ }

"and"       {   
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, AND, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }       
            }
"break"     {                      
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, BREAK, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }                                                        
            }
"continue"  {                      
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, CONTINUE, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }                                                        
            }
"def"       {                    
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, DEF, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }        
            }
"elif"      {                        
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, ELIF, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }      
            }
"else"      {                    
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, ELSE, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }                                                        
            }
"for"       {                        
              yylval.str = NULL;              
              loc.first_line = loc.last_line = yylineno;                 
              int status = yypush_parse(pstate, FOR, &yylval, &loc);   
              if (status != YYPUSH_MORE) {                              
                yypstate_delete(pstate);                                
                return status;                                          
              }       
            }
"if"        { 
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, IF, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }        
              
            }
              
"not"       {                      
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, NOT, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }        
             }
              
"or"        {                    
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, OR, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }    
             }
              
"return"    {                        
                yylval.str = NULL;            
                loc.first_line = loc.last_line = yylineno;               
                int status = yypush_parse(pstate, RETURN, &yylval, &loc); 
                if (status != YYPUSH_MORE) {                             
                  yypstate_delete(pstate);                               
                  return status;                                         
                }        
              }
              
"while"     {                  
                yylval.str = NULL;            
                loc.first_line = loc.last_line = yylineno;               
                int status = yypush_parse(pstate, WHILE, &yylval, &loc); 
                if (status != YYPUSH_MORE) {                             
                  yypstate_delete(pstate);                               
                  return status;                                         
                }         
                
             }

"True"      {                       
                yylval.str = yytext ? new std::string(yytext) : NULL;            
                loc.first_line = loc.last_line = yylineno;               
                int status = yypush_parse(pstate, BOOLEAN, &yylval, &loc); 
                if (status != YYPUSH_MORE) {                             
                  yypstate_delete(pstate);                               
                  return status;                                         
                }        
            }
"False"     {                        
                yylval.str = yytext ? new std::string(yytext) : NULL;            
                loc.first_line = loc.last_line = yylineno;               
                int status = yypush_parse(pstate, BOOLEAN, &yylval, &loc); 
                if (status != YYPUSH_MORE) {                             
                  yypstate_delete(pstate);                               
                  return status;                                         
                }        
              }

[a-zA-Z_][a-zA-Z0-9_]*  {                        
                          yylval.str = yytext ? new std::string(yytext) : NULL;            
                          loc.first_line = loc.last_line = yylineno;               
                          int status = yypush_parse(pstate, IDENTIFIER, &yylval, &loc); 
                          if (status != YYPUSH_MORE) {                             
                            yypstate_delete(pstate);                               
                            return status;                                         
                          }         
                      }

-?[0-9]*"."[0-9]+    {                       
                        yylval.str = yytext ? new std::string(yytext) : NULL;            
                        loc.first_line = loc.last_line = yylineno;               
                        int status = yypush_parse(pstate, FLOAT, &yylval, &loc); 
                        if (status != YYPUSH_MORE) {                             
                          yypstate_delete(pstate);                               
                          return status;                                         
                        }         
                      }

-?[0-9]+    {                   
              yylval.str = yytext ? new std::string(yytext) : NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, INTEGER, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }          
            }

"="         {
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, ASSIGN, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }         
            }
"+"         {                       
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, PLUS, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }         
            }
"-"         {                       
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, MINUS, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }         
            }
"*"         {                       
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, MUL, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }     
            }
"/"         {
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, DIV, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }    
            }

"=="        {
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, EQ, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }                                                        
            }
"!="        {                   
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, NEQ, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }                                                        
            }
">"         {                     
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, GT, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }    
            }
">="        {
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, GTE, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }        
            }
"<"         {                       
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, LT, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }     
            }
            
"<="        {                    
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, LTE, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }     
            }

"("         {                 
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, LPAREN, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }         
            }
              
")"         {   yylval.str = NULL;            
                loc.first_line = loc.last_line = yylineno;               
                int status = yypush_parse(pstate, RPAREN, &yylval, &loc); 
                if (status != YYPUSH_MORE) {                             
                  yypstate_delete(pstate);                               
                  return status;                                         
                }
           }

","         { yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, COMMA, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }         
            }
":"         {                  
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, COLON, &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }                                                        
            }

.           {
              std::cerr << "Unrecognized token on line " << yylineno << ": "
                << yytext << std::endl;
                                
              yylval.str = NULL;            
              loc.first_line = loc.last_line = yylineno;               
              int status = yypush_parse(pstate, yytext[0], &yylval, &loc); 
              if (status != YYPUSH_MORE) {                             
                yypstate_delete(pstate);                               
                return status;                                         
              }                                                        
            }

%%
