#!/bin/sh

get_distribution() {
	lsb_dist=""
	# Every system that we officially support has /etc/os-release
	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi
	# Returning an empty string here should be alright since the
	# case statements don't act unless you provide an actual value
	echo "$lsb_dist"
}

delete_images="None"
delete_containers="None"
remove_docker="None"
remove_compose="None"

while [  "$delete_images" != "y" ]  &&  [ "$delete_images" != "n"  ]
do
  read -p 'Do you want to delete all images? (y/n) ' delete_images
done

while [ "$delete_containers" != "y" ] && [ "$delete_containers" != 'n' ]
do
  read -p 'Do you want to delete all containers? (y/n) ' delete_containers
done

while [ "$delete_compose" != "y" ] && [ "$delete_compose" != 'n' ]
do
  read -p 'Do you want to uninstall Docker-compose? (y/n) ' delete_compose
done

while [ "$delete_docker" != "y" ] && [ "$delete_docker" != 'n' ]
do
  read -p 'Do you want to uninstall Docker? (y/n) ' delete_docker
done

do_cleanup() {

  # down the cluster
  sudo docker-compose down

  # remove containers
  if [ "$delete_containers" = "y" ]; then
    sudo docker rm $(sudo docker ps -aq)
  fi

  # remove delete_images
  if [ "$delete_images" = "y" ]; then
    sudo docker rmi $(sudo docker images -q)
  fi

  # uninstall docker
  if [ "$delete_docker" = "y" ]; then
    lsb_dist=$( get_distribution )
    lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"
    case "$lsb_dist" in

      ubuntu)
        sudo apt-get purge docker-ce docker-ce-cli docker-engine docker.io containerd runc -y
        sudo rm -rf /var/lib/docker
        sudo rm -rf /run/docker
        sudo rm -rf /var/run/docker
        sudo rm -rf /var/run/docker.sock
        sudo rm -rf /etc/docker
      ;;

      debian|raspbian)
        sudo apt-get purge docker-ce docker-ce-cli docker-engine docker.io containerd runc -y
        sudo rm -rf /var/lib/docker
        sudo rm -rf /run/docker
        sudo rm -rf /var/run/docker
        sudo rm -rf /var/run/docker.sock
        sudo rm -rf /etc/docker
      ;;

      centos)
        sudo yum remove docker-ce docker-ce-cli docker-engine docker.io containerd runc -y
        sudo rm -rf /var/lib/docker
        sudo rm -rf /run/docker
        sudo rm -rf /var/run/docker
        sudo rm -rf /var/run/docker.sock
        sudo rm -rf /etc/docker
      ;;

      rhel|ol|sles)
        sudo apt-get purge docker-ce docker-ce-cli docker-engine docker.io containerd runc -y
        sudo rm -rf /var/lib/docker
        sudo rm -rf /run/docker
        sudo rm -rf /var/run/docker
        sudo rm -rf /var/run/docker.sock
        sudo rm -rf /etc/docker
      ;;
    esac
  fi

  # uninstall docker-compose
  if [ "$delete_compose" = "y" ]; then
    sudo rm -rf /usr/local/bin/docker-compose
		sudo rm -rf /usr/bin/docker-compose
  fi
  exit 0
}

do_cleanup
