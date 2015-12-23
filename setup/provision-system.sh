#!/usr/bin/env bash

DIR="$(dirname $BASH_SOURCE)"
distro=$1

source  "$DIR/getColorStyleBackground.sh"
export SC1=$( getColorStyleBackground Red Bold Black )
export SC2=$( getColorStyleBackground Green Bold Black )
export SC3=$( getColorStyleBackground Yellow Bold Black )

echo -e "${SC1}"
echo "***************************************************"
echo "Provisioning the system..."
echo "***************************************************"
echo "Param1       : $1"
echo "BASH_SOURCE  : $BASH_SOURCE"
echo "DIR          : $DIR"
echo "distro       : $distro"
echo "EUID         : $EUID"




if [ "$EUID" -ne 0 ]; then
  echo "This must be run as root"
  exit 1
fi

if [ -z $distro ]; then
  >&2 echo "A distro must be specified for provisioning"
  exit 1
fi

export SCRIPTDIR="$DIR/distro/$distro"
export TEMPDIR=$(mktemp -d)




echo "SCRIPTDIR    : $SCRIPTDIR"
echo "TEMPDIR      : $TEMPDIR"


if [[ ! -d $SCRIPTDIR ]]; then
  >&2 echo "A provisioning directory does not exist for '$distro'"
  exit 1
fi

echo -e "\n\n"
echo "----------------------------------------------------"
echo "Exporting functions of...                          |"
echo "---------------------------------------------------|"

# Export functions to be used throughout the build scripts
functions=$(find "$DIR/functions" -maxdepth 1 -type f)
for fscript in $functions; do
  # Find the base name of the file and split it by '.'
  fscript_basename=$(basename "$fscript")
  fscript_parts=(${fscript_basename/./ })
  fname=${fscript_parts[0]}
  # Source and then export the function
  . "$fscript"
  export -f $fname
  # debug
  echo "file: $fscript "
done

echo "---------------------------------------------------"
echo -e "\n\n"


# Find all of the files that begin with two numbers and sort them
scripts=$(find "$SCRIPTDIR" -maxdepth 1 -type f -name "[0-9][0-9]*" | sort)
for script in $scripts; do
  # debug
  echo -e "${SC1}"
  echo -e "\n\n"
  echo "***************************************************"
  echo "Execute script: $script "
  echo "***************************************************"
  echo -e "\n\n"
  echo -e "${NC}"

  # execute
  "$script"
  ret=$?
  if [[ $ret -ne 0 ]]; then
    >&2 "Aborting There was an error with $script"
    exit $ret
  fi
done

echo -e "\n\n"
echo -e "${SC1}"
echo "---------------------------------------------------|"
echo "All scripts executed                               |"
echo "---------------------------------------------------|"
echo -e "\n\n"


echo "All provisioning source is located at:"
echo "$TEMPDIR\n"

echo -e "${NC}"
echo -e "\n\n"

exit 0

