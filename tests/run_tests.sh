#! /bin/bash

TESTS_DIR="tests/"
TESTS_OUTPUT_DIR="output"
BUILD_DIR="$(pwd)/build"
EXE=""
OUTPUT_FILE_EXTENSION=""

BEGIN_TESTS_MSG=""
TEST_SUCCESS_MSG="Testcase Passed"
TEST_FAILURE_MSG="Testcase Failed"
ALL_TESTS_SUCCESSFUL_MSG=""
TESTS_FAILED_MSG=""

EXPECTED_ERROR_MSG=""
SHOULD_FAIL=0

RED="\e[0;31m"; GREEN="\e[0;32m"; YELLOW="\e[0;33m"; BLUE="\e[0;34m"; WHITE="\e[0;0m"
B="\e[1m"; I="\e[3m"; U="\e[4m"; NC="\e[0m"

lexer_correct_codes_test(){
	TESTS_DIR+="Lexer_Tests/Correct_codes"
	EXE="${BUILD_DIR}/lexer"
	OUTPUT_FILE_EXTENSION=".token"

	BEGIN_TESTS_MSG="Running testcases with lexicologically correct code for the Lexical Analyzer"
	ALL_TESTS_SUCCESSFUL_MSG="All valid Lexical Analyzer testcases passed!"
	TESTS_FAILED_MSG="Lexical Analyzer testcases failed!"

	EXPECTED_ERROR_MSG="Invalid token"
	SHOULD_FAIL=0
}

lexer_incorrect_codes_test(){
	TESTS_DIR+="Lexer_Tests/Incorrect_codes"
	EXE="${BUILD_DIR}/lexer"
	OUTPUT_FILE_EXTENSION=".token"

	BEGIN_TESTS_MSG="Running testcases with lexicologically incorrect code for the Lexical Analyzer"
	TEST_SUCCESS_MSG="Testcase Passed, as the invalid tokens are rejected by the lexer"
	ALL_TESTS_SUCCESSFUL_MSG="All invalid tokens were rejected by the Lexical Analyzer."
	TESTS_FAILED_MSG="Lexical Analyzer testcases failed!"

	EXPECTED_ERROR_MSG="Invalid token"
	SHOULD_FAIL=1
}

parser_correct_codes_test(){
	TESTS_DIR+="Parser_Tests/Correct_codes"
	EXE="${BUILD_DIR}/parser"
	OUTPUT_FILE_EXTENSION=".parser-trace"

	BEGIN_TESTS_MSG="Running testcases with syntactically correct code for the Parser"
	ALL_TESTS_SUCCESSFUL_MSG="All syntactically valid testcases passed!"
	TESTS_FAILED_MSG="Parser testcases failed!"

	EXPECTED_ERROR_MSG="syntax error"
	SHOULD_FAIL=0
}

parser_incorrect_codes_test(){
	TESTS_DIR+="Parser_Tests/Incorrect_codes"
	EXE="${BUILD_DIR}/parser"
	OUTPUT_FILE_EXTENSION=".parser-trace"

	BEGIN_TESTS_MSG="Running testcases with syntactically incorrect code for the Parser"
	TEST_SUCCESS_MSG="Testcase Passed. All syntax errors detected"
	TEST_FAILURE_MSG="Testcase Failed"
	ALL_TESTS_SUCCESSFUL_MSG="All syntax errors were caught by the parser!"
	TESTS_FAILED_MSG="Parser testcases failed!"

	EXPECTED_ERROR_MSG="syntax error"
	SHOULD_FAIL=1
}

semn_correct_codes_test(){
	TESTS_DIR+="Semantic_Tests/Correct_codes"
	EXE="${BUILD_DIR}/parser_with_semantic_analysis"
	OUTPUT_FILE_EXTENSION=".sym"

	BEGIN_TESTS_MSG="Running testcases with syntactically and semantically correct code for the Parser"
	ALL_TESTS_SUCCESSFUL_MSG="All semantically valid testcases passed!"
	TESTS_FAILED_MSG="Semantic analysis testcases failed!"

	EXPECTED_ERROR_MSG="Semantic Error:"
	SHOULD_FAIL=0
}

semn_incorrect_codes_test(){
	TESTS_DIR+="Semantic_Tests/Incorrect_codes"
	EXE="${BUILD_DIR}/parser_with_semantic_analysis"
	OUTPUT_FILE_EXTENSION=".sym"

	BEGIN_TESTS_MSG="Running testcases with syntactically valid but semantically incorrect codes for the Parser"
	ALL_TESTS_SUCCESSFUL_MSG="All semantic errors were caught by the parser!"
	TESTS_FAILED_MSG="Semantic analysis testcases failed!"

	EXPECTED_ERROR_MSG="Semantic Error:"
	SHOULD_FAIL=1
}

correct_testcase_demo(){
	TESTS_DIR+="Final_Demo/Correct_codes"
	EXE="${BUILD_DIR}/parser_debug"
	OUTPUT_FILE_EXTENSION=".parser-trace"

	BEGIN_TESTS_MSG="Running non-trivial correct tangent example"
	ALL_TESTS_SUCCESSFUL_MSG="Testcase Successful!"
	TESTS_FAILED_MSG="Semantic analysis testcases failed!"

	EXPECTED_ERROR_MSG="Error:"
	SHOULD_FAIL=0
}

incorrect_testcase_demo(){
	TESTS_DIR+="Final_Demo/Incorrect_codes"
	EXE="${BUILD_DIR}/parser_debug"
	OUTPUT_FILE_EXTENSION=".parser-trace"

	BEGIN_TESTS_MSG="Running non-trivial incorrect tangent example"
	ALL_TESTS_SUCCESSFUL_MSG="Testcase Successful! All errors were caught by the compiler!"
	TESTS_FAILED_MSG="Semantic analysis testcases failed!"

	EXPECTED_ERROR_MSG="Error:"
	SHOULD_FAIL=1
}

# Call the appropriate test function
"$1"

# Run the tests on all the testcases located in the TESTS_DIR directory
cd "${TESTS_DIR}" || (echo "${TESTS_DIR} not found" && exit 1)
mkdir -p "${TESTS_OUTPUT_DIR}"
TEST_CODES=(*.tngt)
SUCCESSFUL=0; FAILED=0; TOTAL=${#TEST_CODES[@]}

echo -e "${WHITE}\n###################################################################################${NC}\n"; 
echo -e "${BLUE}${B}${U}${BEGIN_TESTS_MSG}${NC}\n";
for testcase in "${TEST_CODES[@]}"; do testcase="${testcase%.*}"
	echo -e "${YELLOW}${I}Running Testcase ($((SUCCESSFUL+FAILED+1))/${TOTAL}): ${testcase}.tngt${NC}${I}${NC} ~> ${testcase}${OUTPUT_FILE_EXTENSION}"

	# Run the testcase
	"${EXE}" "${testcase}.tngt" > "${TESTS_OUTPUT_DIR}/${testcase}${OUTPUT_FILE_EXTENSION}"

	ERRORS_RECIEVED=0; 
	if [ "$(grep "${EXPECTED_ERROR_MSG}" ${TESTS_OUTPUT_DIR}/"${testcase}${OUTPUT_FILE_EXTENSION}" | wc -w)" -eq 0 ] ; then 
		ERRORS_RECIEVED=1; fi
	
	if [ "${ERRORS_RECIEVED}" -ne ${SHOULD_FAIL} ] ; then
		echo -e "${GREEN}\t${TEST_SUCCESS_MSG}\n${NC}"; SUCCESSFUL=$((SUCCESSFUL+1))
	else 
		echo -e "${RED}\t${TEST_FAILURE_MSG}\n${NC}"; FAILED=$((FAILED+1)); fi
done

if [ ${SUCCESSFUL} -eq "${TOTAL}" ] ; then
	echo -e "${GREEN}${B}Success: ${ALL_TESTS_SUCCESSFUL_MSG} ${NC} (Outputs can be viewed in ${TESTS_DIR}/${TESTS_OUTPUT_DIR})\n"
else
	echo -e "${RED}Error: ${FAILED}/${TOTAL} ${TESTS_FAILED_MSG} ${NC} (Outputs can be viewed in ${TESTS_DIR}/${TESTS_OUTPUT_DIR})\n"
fi;