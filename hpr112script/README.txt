Setup AKS, ACR and a agent-host machine with agents

How to:
1. Download this folder on the computer you want to use for administration
2. Start powershell as administrator
3. Run script install-azCLI-kubectl.ps1
   (this wil probebly reboot the system, if so open powershell as admin again after reboot)
4. Run script deployAzure.ps1 to deploy AKS, ACR and a VM for agent hosting
   (now is some configuration requried)
5. After configuration make sure you ar logged in to the linuxVM
6.On the linuxVM; 
 6.1 run command chmod +x LinuxAgentHost.sh
 6.2 run script LinuxAgentHost.sh
      (Some configuration is requried)
