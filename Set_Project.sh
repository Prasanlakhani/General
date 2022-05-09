s48f053@cloudshell:~/Scripts (otc-camp-prod-1894)$ cat set.sh
#!/bin/bash
export PATH=/home/s48f053/Scripts:$PATH
#********************************************
# Created by Prasan Lakhani
# Version 1.0 / #Set project / gcloud config set project [PROJECT_ID]
#********************************************

#Function : If Syntax is wrong
usage (){
            echo "----------------------------------------------------------------------------"
            echo "Use it like this : "
                echo "./set.sh project_name"
                echo ""
            echo "----------------------------------------------------------------------------"

                }

#pwd
# Non

# If Syntax is Wrong, go to Usage function & exit
if [[ $1 == "" ]] ;then
        usage
                exit 1
        else
                if [[ $1 == "cat" ]] || [[ $1 == "con" ]] || [[ $1 == "nvp" ]] || [[ $1 == "ccn" ]] ;then
                        if [[ $1 == "cat" ]]; then
                        gcloud config set project core-automation-test-fddb
                        fi
                        if [[ $1 == "con" ]]; then
                        gcloud config set project cops-osmon-nonprod-b6c0
                        fi
                        if [[ $1 == "nvn" ]]; then
                        gcloud config set project net-vpc-nonprod-318a
                        fi
                        if [[ $1 == "ccn" ]]; then
                        gcloud config set project cops-cloudmonus-nonprod-563b
                        fi
                else
                        #List all the project & search for $1
                        Project_1=$(gcloud projects list | grep -i PROJECT_ID: | grep $1 | awk '{print $2}')
                                if [[ $Project_1 == "" ]] ;then
                                        #If Project name is not found
                                        echo "Project ($Project_1) not Found"
                                        exit 1
                                fi

                        Project_2=$(echo $Project_1)
                        gcloud config set project $Project_2
                        echo "Project set to $Project_2"
                fi
fi
