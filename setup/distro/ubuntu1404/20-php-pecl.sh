#!/usr/bin/env bash
# Environment variables SCRIPTDIR and TEMPDIR are available
. $SCRIPTDIR/functions/php.sh



echo -e "\n\n"
echo -e "${SC2}"
echo "---------------------------------------------------|"
echo "Install pecl from $SCRIPTDIR/lists/pecl"
echo "---------------------------------------------------|"
echo "packages: $packages"
echo -e "${NC}"
echo -e "\n\n"


list=$(readlist "$SCRIPTDIR/lists/pecl")
for extension in $list
do

  # debug
  echo -e "${SC3}"
  echo -e "\n\n"
  echo "extension: $extension "
  echo -e "\n\n"
  echo -e "${NC}"


  php-pecl-install $extension
  #[[ $? -ne 0 ]] && exit 1
done





exit 0
