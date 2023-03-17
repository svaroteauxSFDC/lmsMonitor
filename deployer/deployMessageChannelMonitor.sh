#!/bin/bash

imports=""          #contains import strings
sets=""             #contains set strings 
packagePrefix=""    #contains Lightning Message Channel prefix (package)
channelName=""      #contains Lightning Message Channel developerName

newLine=$'\n'

echo ""
echo "###############################################"
echo "#####  Lightning Message Channel Monitor  #####"
echo "#####       .::Deployment tools::.        #####"
echo "#####                                     #####"
echo "#####    This script is supposed to be    #####"
echo "#####      executed from it's folder      #####"
echo "###############################################"
echo ""

echo "Retrieve SFDX Orgs list"
sfdx org list

echo "Which org known by sfdx is the target to retrieve Lightning Message Channels?"
read -p "Enter SFDX Org prefix: " orgName

echo "use SFDX to discover Lightning Message Channels"
channels=$(sfdx data query -t -q "select DeveloperName, NamespacePrefix from LightningMessageChannel" -o ${orgName} -r csv)
build_list=($channels)

echo "Channels récupérés"
for n in "${build_list[@]:1}"
do
    IFS=',' read -ra splitValues <<< "$n"
    channelName="${splitValues[0]}"
    packagePrefix="${splitValues[1]}"
    channelIndentifier="" 

    if [ ${#packagePrefix} -gt 0 ]
        then
            packagePrefix="${packagePrefix}__"
        else
            packagePrefix=""
    fi

    channelIndentifier="${packagePrefix}${channelName}"
    echo "Adding reference to ${channelIndentifier}"
    imports="${imports}import ${channelIndentifier} from '@salesforce/messageChannel/${channelIndentifier}__c';${newLine}"
    sets="${sets}channels.set('${channelIndentifier}', ${channelIndentifier});${newLine}"
done

echo "Update destination file: ../force-app/main/default/lwc/monitorHelpers/monitorHelpers.js"
template=$(cat ./monitorHelpers.template)
find="//<imports>"
final=${template//$find/$imports}

find="//<channels>"
final=${final//$find/$sets}

printf "$final" > ../force-app/main/default/lwc/monitorHelpers/monitorHelpers.js

read -p "Deployment to '${orgName}'? (y/n) " deployNow 

if [ "$deployNow" == "y" ]
    then
        echo "Deployment confirmed"
        cd ..
       sfdx force source push -f -u $orgName
        cd deployer
    else
        echo "No deployment"
fi

echo "###############################################"
echo "#####              JOB DONE!              #####"
echo "###############################################"
