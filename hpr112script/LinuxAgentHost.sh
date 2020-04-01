#!/bin/bash

sudo apt-get update
sudo apt-get install docker.io
sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo apt-get install -y unzip

sudo chmod +x /usr/local/bin/docker-compose

sudo groupadd docker
sudo usermod -a -G docker $USER

sudo systemctl start docker
sudo systemctl enable docker

wget https://vstsagentpackage.azureedge.net/agent/2.165.2/vsts-agent-linux-x64-2.165.2.tar.gz -P ~/

echo How many agents would you like to setup?

read agents

for agent in $(seq 1 $agents)
		do
		mkdir agent$agent && cd agent$agent
		tar zxvf "../vsts-agent-linux-x64-2.165.2.tar.gz"
		echo "Setting up agentnumber $agent"
		./config.sh

		sudo ./svc.sh install
		sudo ./svc.sh start

		cd ..

		if [ "$agent" -eq "$agents" ]
		then
			echo "All agents ready. Reboot required, rebooting now.."
			sleep 3
			sudo reboot
		fi
	done




