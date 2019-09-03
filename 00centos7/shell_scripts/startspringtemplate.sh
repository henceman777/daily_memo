#!/bin/bash

argn=$#
if [[ $argn > 1 ]]; then
    echo "Illegal number of arguments!"
    exit 0
elif [[ $argn == 1 ]]; then
    if [[ $1 == 'reset' ]]; then
        output=$(git reset --hard master)
        printf "Remove the old project: (y/N)"
        read flag
        l_flag=`echo "${flag}" | awk '{print tolower($0)}'`
        if [[ ${l_flag} == 'y' ]]; then
            git clean -fd
            echo "Remove done!"
        fi
        echo "Project has been reset!"
    fi
    exit 0
fi

#determine platform
platform='unknown'
if [ "$(uname)" == "Darwin" ]; then
    platform='osx'
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    platform='linux'
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    platform='win32'
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    platform='win64'
fi

printf "Project name(Upper case for the initial letter, eg: Apple): "
read name

convert_to_lower() {
    echo "$1" | awk '{print tolower($0)}'
}

convert_str() {
    echo "$1" | perl -ne "print lc(join(\"$2\", split(/(?=[A-Z])/)))"
}

convert_to_lower_camel() {
    perl -le 'print lcfirst shift' "$1"
}

OLD_NAME="SpringTemplate"
TARGET=$name
L_OLD_NAME=$(convert_to_lower "${OLD_NAME}")
L_TARGET=$(convert_to_lower "${TARGET}")
L_US_OLD_NAME=$(convert_str "${OLD_NAME}" "-")
L_US_TARGET=$(convert_str "${TARGET}" "-")
L_SLASH_OLD_NAME=$(convert_str "${OLD_NAME}" "/")
L_SLASH_TARGET=$(convert_str "${TARGET}" "/")
L_DOT_OLD_NAME=$(convert_str "${OLD_NAME}" "\.")
L_DOT_TARGET=$(convert_str "${TARGET}" ".")
L_COLON_OLD_NAME=$(convert_str "${OLD_NAME}" ":")
L_COLON_TARGET=$(convert_str "${TARGET}" ":")
L_REAL_US_OLD_NAME=$(convert_str "${OLD_NAME}" "_")
L_REAL_US_TARGET=$(convert_str "${TARGET}" "_")
L_CAMEL_OLD_NAME=$(convert_to_lower_camel "${OLD_NAME}")
L_CAMEL_TARGET=$(convert_to_lower_camel "${TARGET}")
PROJECT_NAME=${L_US_TARGET}

RENAME_CMD='mv "$0" "${0//'${OLD_NAME}'/'${TARGET}'}"'
L_RENAME_DIR_CMD='mkdir -p ../$(dirname "$1"); mv $0 ../${1}'
L_US_RENAME_CMD='mv "$0" "${0//'${L_US_OLD_NAME}'/'${L_US_TARGET}'}"'

# copy to a new project
cp -rf code-template ${PROJECT_NAME}

rename_dirs() {
    find ./${PROJECT_NAME} -depth -name "*${1}*" -execdir bash -c "${2}" {} \;
}

rename_files() {
    find ./${PROJECT_NAME} -depth -name "*${1}*" -type f -exec bash -c "${2}" {} \;
}

#rename folder
rename_dirs "${OLD_NAME}" "${RENAME_CMD}"
rename_dirs "${L_US_OLD_NAME}" "${L_US_RENAME_CMD}"

find ./${PROJECT_NAME} -depth -type d -name "$(basename "$L_SLASH_OLD_NAME")" -execdir bash -c "${L_RENAME_DIR_CMD}" {} "${L_SLASH_TARGET}" \;
find ./${PROJECT_NAME} -depth -type d -name "$(dirname "$L_SLASH_OLD_NAME")" -exec rm -r {} \;
echo "Rebuild directory done!"

# rename file
rename_files "${OLD_NAME}" "${RENAME_CMD}"
rename_files "${L_US_OLD_NAME}" "${L_US_RENAME_CMD}"
echo "Rebuild file done!"

replace_in_files() {
    if [[ $platform == 'osx' ]]; then
        grep -rl "${1}" ./${PROJECT_NAME} | grep -v 'start.sh' | xargs sed -i '' "${2}"
    else
        grep -rl "${1}" ./${PROJECT_NAME} | grep -v 'start.sh' | xargs sed -i "${2}"
    fi
}

#replace content
REGEX='s/'${OLD_NAME}'/'${TARGET}'/g'
L_US_REGEX='s/'${L_US_OLD_NAME}'/'${L_US_TARGET}'/g'
L_DOT_REGEX='s/'${L_DOT_OLD_NAME}'/'${L_DOT_TARGET}'/g'
L_COLON_REGEX='s/'${L_COLON_OLD_NAME}'/'${L_COLON_TARGET}'/g'
L_REAL_US_REGEX='s/'${L_REAL_US_OLD_NAME}'/'${L_REAL_US_TARGET}'/g'
L_CAMEL_REGEX='s/'${L_CAMEL_OLD_NAME}'/'${L_CAMEL_TARGET}'/g'

replace_in_files "${OLD_NAME}" "${REGEX}"
replace_in_files "${L_US_OLD_NAME}" "${L_US_REGEX}"
replace_in_files "${L_COLON_OLD_NAME}" "${L_COLON_REGEX}"
replace_in_files "${L_REAL_US_OLD_NAME}" "${L_REAL_US_REGEX}"
replace_in_files "${L_CAMEL_OLD_NAME}" "${L_CAMEL_REGEX}"
replace_in_files "${L_DOT_OLD_NAME}" "${L_DOT_REGEX}"

echo "Exam for all contents passed!"

printf "Use default gradle wrapper: (y/n)"
read flag
l_flag=`echo "${flag}" | awk '{print tolower($0)}'`
if [[ ${l_flag} == 'y' || ${l_flag} == '' ]]; then
    cp -rf .gradle-wrapper ./${PROJECT_NAME}/gradle
    echo "Default gradle wrapper is generated successfully!"
fi

echo "Congratulations! Now move your ass and write some code."


