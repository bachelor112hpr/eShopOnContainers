Setup AKS, ACR and a agent-host machine with agents

How to:
1. Download this folder on the computer you want to use for administration
2. Start powershell as administrator
3. Run script install-azCLI-kubectl.ps1
   (this wil probebly reboot the system, if so open powershell as admin again after reboot)
4. Run script Connect-to-Azure.ps1 
5. Run script deployAzure.ps1 to deploy AKS, ACR and a VM for agent hosting
   (run trough configuration)
. Run script LinuxVM.ps1
.On the linux-vm; 
 .1 run command chmod +x LinuxAgentHost.sh
 .2 run script LinuxAgentHost.sh
