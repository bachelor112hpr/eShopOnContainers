Write-host '
#############################
# CONNECT TO AZURE ACCOUNT: #
############################# ' -ForegroundColor Green

$account = Read-Host -Prompt 'Is your account a Microsoft account (Enter for Yes)'

if(-not($account)){
	az login
}
else{
	$azUser = Read-Host -Prompt 'Azure username'
	$azPwd = Read-Host 'Enter password' -AsSecureString 
	az login -u $azUser -p $azPwd
}