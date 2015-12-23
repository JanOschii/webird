#!/usr/bin/env bash
# Environment variables SCRIPTDIR and TEMPDIR are available

echo -e "\n\n"
echo -e "${SC2}"
echo "---------------------------------------------------|"
echo "Update apt-get and install 'software-properties-common' "
echo "---------------------------------------------------|"
echo -e "${NC}"
echo -e "\n\n"

# Update to get package list
apt-get -q update
# Install add-apt-repository command
apt-get -q -y install software-properties-common



echo -e "\n\n"
echo -e "${SC2}"
echo "---------------------------------------------------|"
echo "Install MariaDB                                    |"
echo "---------------------------------------------------|"
echo -e "${NC}"
echo -e "\n\n"

# MariaDB Ubuntu PPA
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
add-apt-repository 'deb http://mariadb.mirror.nucleus.be//repo/10.1/ubuntu trusty main'



echo -e "\n\n"
echo -e "${SC2}"
echo "---------------------------------------------------|"
echo "Install Nginx Stable Ubuntu PPA                    |"
echo "---------------------------------------------------|"
echo -e "${NC}"
echo -e "\n\n"

# Nginx Stable Ubuntu PPA
add-apt-repository ppa:nginx/stable



echo -e "\n\n"
echo -e "${SC2}"
echo "---------------------------------------------------|"
echo "Update apt-get after PPA changes                   |"
echo "---------------------------------------------------|"
echo -e "${NC}"
echo -e "\n\n"

# Update again after PPA changes
apt-get update
apt-get upgrade -y





packages=$(readlist "$SCRIPTDIR/lists/package")

echo -e "\n\n"
echo -e "${SC2}"
echo "---------------------------------------------------|"
echo "Install packages from $SCRIPTDIR/lists/package"
echo "---------------------------------------------------|"
echo "packages: $packages"
echo -e "${NC}"
echo -e "\n\n"


for package in $packages; do
  # debug
  echo -e "${SC3}"
  echo -e "\n\n"
  echo "package: $package "
  echo -e "\n\n"
  echo -e "${NC}"

  apt-get -q -y install $package

done


echo -e "\n\n"
echo -e "${SC2}"
echo "---------------------------------------------------|"
echo -e "${NC}"
echo -e "\n\n"

exit 0
