#!/bin/bash
set -e

mainEnv=".env"
localEnv=".env.local"
isValidEnv=true

printCurrentDir() {
  currentDirName=$(basename "$(pwd)")
  echo -e "Start check \e[1;32m$currentDirName\e[0m project variables"
}

getVariables() {
  # Remove comments and empty lines
  filtered_output=$(grep -v -E '^\s*(#|$)' "$1")
  # Extract variable names before '='
  echo "$filtered_output" | cut -d '=' -f 1
}

# Function to sort and convert the variable list to newline-separated format
sortAndConvertToNewline() {
    echo "$1" | tr ' ' '\n'|sort
}

getUniqueRowFromFirstFile() {
  echo $(comm -23 <(sortAndConvertToNewline "$1") <(sortAndConvertToNewline "$2"))
}

printCurrentDir

mainEnvVariableContainer=$(getVariables "$mainEnv")
localEnvVariableContainer=$(getVariables "$localEnv")

notPresentedInLocal=$(getUniqueRowFromFirstFile "$mainEnvVariableContainer" "$localEnvVariableContainer")
if [ -n "$notPresentedInLocal" ]; then
  echo "Variables from $mainEnv not present in $localEnv:"
  echo $notPresentedInLocal
  isValidEnv=false
fi

redundantLocalVariable=$(getUniqueRowFromFirstFile "$localEnvVariableContainer" "$mainEnvVariableContainer")
if [ -n "$redundantLocalVariable" ]; then
  echo "Variables from $localEnv not exist in $mainEnv:"
  echo $redundantLocalVariable
  isValidEnv=false
fi

if [ "$isValidEnv" = false ]; then
    echo -e "\e[1;31mError: The local env variable do not match with .env. Run 'cp .env .env.local' or resolve manually\e[0m"
    exit 1
fi

echo -e "\e[1;32mEnv variables match\e[0m"
exit 0;
