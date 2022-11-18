CC = g++
LLVM_INC_DIR = $(wildcard /usr/include/llvm*)

# Input and output directories
SRC_DIR := ./src
BUILD_DIR := ./build

.PHONY : all compiler lexer parser parser_documentation tests lexer_tests lexer_correct_codes lexer_incorrect_codes \
	parser_tests parser_correct_codes parser_incorrect_codes clean

# Default target
all: compiler
compiler: parser

# $@ = build target of the rule (lhs)  ($(@D) = Directory of the $@, and $(@F) = only filename of $@. Similarly for others)
# $^ = dependencies of the rule (rhs)
# $< = first dependency of the rule (first value in the rhs)
$(BUILD_DIR)/lex.yy.cc: $(SRC_DIR)/lexer.l
	mkdir -p $(@D)
	flex -o $@ $^

$(BUILD_DIR)/parser.cc \
$(BUILD_DIR)/parser.hh: $(SRC_DIR)/parser.yy
	mkdir -p $(@D)
	bison -o $(BUILD_DIR)/parser.cc $^

# Build an executable to scan the input tangent code and output the matched tokens
lexer: $(BUILD_DIR)/lex.yy.cc $(BUILD_DIR)/parser.hh
	$(CC) -std=c++2a -o $(BUILD_DIR)/$@ $< $(LLVM_INC_DIR:%=-I%) -D STANDALONE_LEXER

# Build an executable to parse the input tangent code files according to the grammar rules
parser: $(BUILD_DIR)/parser.cc $(BUILD_DIR)/lex.yy.cc $(SRC_DIR)/astNodes.cpp $(SRC_DIR)/symbolTable.cpp
	$(CC) -std=c++2a -g -o $(BUILD_DIR)/$@ $^ $(LLVM_INC_DIR:%=-I%) -D PARSER_TRACE_DEBUG -D SYMBOL_TABLE_DEBUG

# Generate HTML documentation describing our grammar and the DFA representing the parser.
parser_documentation: $(SRC_DIR)/parser.yy
	mkdir -p $(BUILD_DIR)
	bison -o $(BUILD_DIR)/parser.cc $< --verbose --xml=$(BUILD_DIR)/$(<F:%.y=%.xml)
	xsltproc $$(bison --print-datadir)/xslt/xml2xhtml.xsl $(BUILD_DIR)/$(<F:%.y=%.xml) > ./documentation/$(<F:%.y=%.html)
	xdg-open ./documentation/$(<F:%.y=%.html)


# Remove all generated files
clean:
	rm -rf $(BUILD_DIR) $$(find . -type d -name $(TESTS_OUTPUT_DIR))


#################### TESTING RULES ########################

TESTS_DIR := ./tests
TESTS_OUTPUT_DIR := output

# Test the compiler against the testcases located in ./tests
tests: lexer_tests parser_tests

lexer_tests: lexer_incorrect_codes_test lexer_correct_codes_test
parser_tests: parser parser_incorrect_codes_test parser_correct_codes_test

lexer_correct_codes_test \
lexer_incorrect_codes_test: lexer
	bash $(TESTS_DIR)/run_tests.sh $@

parser_correct_codes_test \
parser_incorrect_codes_test: parser
	bash $(TESTS_DIR)/run_tests.sh $@