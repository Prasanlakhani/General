#!/bin/bash
	#************************************************************************************************************************************
	# Company    : Atos
	# Created by : Prasan Lakhani 
	# DAS ID 	 : A517965
	# Email ID   : prasanchandra.lakhani@atos.net
	#
	# Desciption : Script automates some steps of project onboarding 
	#
	# Version="4.2" / Redesign Folder Structure  / Add lite version feature / Zip File / Developer version
	#			
	# < project_name >		: Generally project_name is WWW-XXX-YYY-ZZZ 
	#                         You can only provide WWW-XXX-YYY and script fetches last ZZZ automatically
	#   
	# Limitation : Can identify 10 network Tags per instance
	# 			 : Can identify 5  nic cards per instance
	#			 : Can identify 10 Disk per instance			
	#************************************************************************************************************************************
	
	#************************************************************************************************************************************
	# Copyright ©2020. Atos. All Rights Reserved. 
	#
	# No permission to use, copy, modify or distribute this software and its documentation is granted except with the prior written approval of Atos. 
	# Please refer to the agreement under which you have been given access to this software for other applicable terms and conditions.
	#
	# IN NO EVENT SHALL ATOS BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, 
	# ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF ATOS HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	# 
	# ATOS SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
	# FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". 
	# ATOS HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS EXCEPT IF APPLICABLE CONTRACTUAL TERMS 
	# AND CONDITIONS PROVIDE OTHERWISE.
	#*************************************************************************************************************************************

	#Script Version : 
	Version="v4.2"	
	
	#Function
	usage (){									# Shows how to use the Script

			echo "----------------------------------------------------------------------------------------------------------------"
			echo "Script Created by Prasan Lakhani"
			echo "----------------------------------------------------------------------------------------------------------------"
			echo "run ./Dashboard.sh -p <Project Name>								# To get info for single Service project"    
			echo "run ./Dashboard.sh -p net-vpc-prod -r								# Download Fresh/Updated Teamplate from host Project"
			echo "run ./Dashboard.sh -p net-vpc-prod -r ADHOC_DASHBAORD_TEMPLATE	# If you want to add Addhoc widgets in dashboard"
			echo "run ./Dashboard.sh -f <File_Name>									# To get info from multiple Service Project"
			echo "run ./Dashboard.sh -p <File_Name>	-r <Project_name>				# If you want special customized template, rest service will be excluded"
			echo ""
			echo "cat <File_Name>"
			echo "Project_Name 1"
			echo "Project_Name 2"
			echo "Example :  ./Dashboard.sh -p net-vpc-prod 						#Service Project "
			echo "Example :  ./Dashboard.sh -f Project_list.txt						#List of Service Projects "
			echo "----------------------------------------------------------------------------------------------------------------"
			echo "Fetch new/updated DASHBOARD use -r flag							#When you make changes to Dashboard GUI in core-automation-test, you need to use -r "							
			echo "Example :  ./Dashboard.sh -p net-vpc-prod -r "
			echo "----------------------------------------------------------------------------------------------------------------"
			echo "Add Adhoc Widget, for which the service is not yet enable or for XYZ reason use :"
			echo "Example :  ./Dashboard.sh -p net-vpc-prod -r ADHOC_DASHBAORD_TEMPLATE"
			echo "Please Note :  ADHOC_DASHBAORD_TEMPLATE should exist in host project"
			echo "----------------------------------------------------------------------------------------------------------------"
			echo "Add Customized Dashboard <project name only>, rest of the service will be excluded :"
			echo "Example :  /Dashboard.sh -p net-vpc-prod	-r net-vpc-prod"
			echo "Please Note :  net-vpc-prod dashboard should exist in host project "
			echo "----------------------------------------------------------------------------------------------------------------"
			echo "Host Project : core-automation-test"
			
	}



	###################FILE DEFINATION########################################
	WORKINGDIR=$(pwd)
	OUTPUTDIR=$WORKINGDIR/custom_dashboard
	PROJECTDIR=$OUTPUTDIR/json_project
	TEMPLATEDIR=$OUTPUTDIR/json_template
	WIDGETDIR=$OUTPUTDIR/json_widget  
	GITHUBDIR=$OUTPUTDIR/GITHUB
	MISCDIR=$OUTPUTDIR/misc
	GITPARENTDIR=$GITHUBDIR/core-gcp-stackdriver-monitoring
	GITCODEDIR=$GITHUBDIR/core-gcp-stackdriver-monitoring/dashboards
	GITSUPPORTDIR=$GITHUBDIR/core-gcp-stackdriver-monitoring/supportfiles
	LOGDIR=$OUTPUTDIR/LOG
	TEMPDIR=$OUTPUTDIR/Temp

	

	###################VARIABLE DEFINATION########################################
	LDate=$(date | tr -d ' ')
	LOGTXT=$LOGDIR/"LOG_"$LDate".log"			

	#API
	ACCESS_TOKEN=`gcloud auth print-access-token`
	#Bucket="json_dashboard"
	Bucket="dashboard_automation"
	
	TEMPLATE_PROJECT_ID="core-automation-test-fddb"
	PARENT_PROJECT_US_DEV="cops-cloudmonus-nonprod-563b"
	PARENT_PROJECT_US_PRO="cops-cloudmonus-prod-b71c"
	PARENT_PROJECT_EU_DEV="cops-cloudmoneu-nonprod-19c7"
	PARENT_PROJECT_EU_PRO="cops-cloudmoneu-prod-d790"
	#PARENT_PROJECT_ID=$PARENT_PROJECT_US_DEV
	#DASHBOARD_ID=""
	TEMP_ID="XXXX-XXXX-XXXX-XXXX"
	SC_FLAG=0
	###################TEMPLATE DEFINATION########################################
	APP_ENGINE_WIDGETNAME="APP_ENGINE_TEMPLATE"
	VM_INSTANCE_WIDGETNAME="VM_INSTANCE_TEMPLATE"
	INTERNAL_LOADBALANCER_WIDGETNAME="INTERNAL_LOADBALANCER_TEMPLATE"
	CLOUD_STORAGE_WIDGETNAME="CLOUD_STORAGE_TEMPLATE"
	CLOUD_SQL_WIDGETNAME="CLOUD_SQL_TEMPLATE"
	CLOUD_MYSQL_WIDGETNAME="CLOUD_MYSQL_TEMPLATE"
	CLOUD_POSTGRES_WIDGETNAME="CLOUD_POSTGRES_TEMPLATE"
	CLOUD_FUNCTIONS_WIDGETNAME="CLOUD_FUNCTIONS_TEMPLATE"
	CLOUD_PUBSUB_WIDGETNAME="CLOUD_PUBSUB_TEMPLATE"
	CLOUD_DATAPROC_WIDGETNAME="CLOUD_DATAPROC_TEMPLATE"
	GKE_CLUSTER_WIDGETNAME="GKE_CLUSTER_TEMPLATE"
	BIG_QUERY_WIDGETNAME="BIG_QUERY_TEMPLATE"
	CLOUD_RUN_WIDGETNAME="CLOUD_RUN_TEMPLATE"
	#GLOBAL_LOADBALANCER_WIDGETNAME="GLOBAL_LOADBALANCER_TEMPLATE"
	#ADHOC_WIDGETNAME=$4
	############################################
	APP_E=0
	VM_I=0
	INTERNAL_L=0
	CLOUD_S=0
	CLOUD_SQL=0
	CLOUD_F=0
	CLOUD_PS=0
	CLOUD_DP=0
	##################################################
	#REGION
	REGION=(us-west1 us-east4 europe-west2 europe-west3 )

	
	###################FOLDER DEFINATION########################################

	if [ ! -d $OUTPUTDIR ]; then				# Output Folder Check

		mkdir $OUTPUTDIR
		COUNTERLOGT=10
		echo $COUNTERLOGT > $MISCDIR/"COUNTER_DONOTDELETE"
		
	fi

	if [ ! -d $PROJECTDIR ]; then				# FinalOutput Folder Check
		
		mkdir $PROJECTDIR
		
	fi
	
	if [ ! -d $TEMPLATEDIR ]; then				# FinalOutput Folder Check
		
		mkdir $TEMPLATEDIR
		
	fi
	
	if [ ! -d $WIDGETDIR ]; then				# FinalOutput Folder Check
		
		mkdir $WIDGETDIR
		
	fi
	
	if [ ! -d $GITHUBDIR ]; then				# FinalOutput Folder Check
		
		mkdir $GITHUBDIR
			
	fi

	if [ ! -d $LOGDIR ]; then					# Log Folder Check
		
		mkdir $LOGDIR
		
	fi
	
	if [ ! -d $MISCDIR ]; then					# Log Folder Check
		
		mkdir $MISCDIR
		
	fi
	
	if [ -d $TEMPDIR ]; then					# Temp Folder Check
		
		rm -rf $TEMPDIR	
		
	fi

		mkdir $TEMPDIR

	if [ -f $MISCDIR/"COUNTER_DONOTDELETE" ]; then
		COUNTERLOGT=$(cat $MISCDIR/"COUNTER_DONOTDELETE")
	else
		COUNTERLOGT=10
		echo $COUNTERLOGT > $MISCDIR/"COUNTER_DONOTDELETE"
	fi

	#TFVAR=$GITPARENTDIR/"terraform.tfvars"
	#TFVAR_TEMP=$TEMPDIR/"terraform.tfvars"
	PROJSON=$MISCDIR/"Misc_"$LDate".txt"		#GOOD
	> $PROJSON

	#####################################################################################################
	#MODULES
	#####################################################################################################

	Counter () {								# Couter for Cleanup										
		
		#COUNTERZIP=$(ls -l $FINALOUTPUT | grep .zip | wc -l)
		#COUNTERCSV=$(ls -l $FINALOUTPUT | grep .csv | wc -l)
		COUNTERLOG=$(ls -l $LOGDIR | grep -i .log | wc -l) 
		COUNTERMIS=$(ls -l $MISCDIR | grep .txt | wc -l ) 
		
		if [[ $COUNTERLOG -ge $COUNTERLOGT ]] ; then
			STAR
			STAR
			echo "Warning from Prasan Lakhani"
			echo "You have used this Script for $COUNTERLOG times"
			echo "Current Usage 		: "
			#echo "Current ZIP File		: $COUNTERZIP 	:  Location : $FINALOUTPUT"
			#echo "Current CSV File		: $COUNTERCSV 	:  Location : $FINALOUTPUT"
			echo "Current Misc File		: $COUNTERMIS 	:  Location : $MISCDIR"
			echo "Current LOG File		: $COUNTERLOG 	:  Location : $LOGDIR"
			echo "Do you want to clean the folder ? (Y/y/N/n)"
			echo "If no clean manually"
			STAR
			read REPLY
			if [[ $REPLY == "Y" ]] || [[ $REPLY == "y" ]] ; then
				#cd $FINALOUTPUT
				#rm *.*
				cd $MISCDIR
				rm *.txt
				cd $LOGDIR
				rm *.*
				cd $WORKINGDIR
				LOGTXT=$LOGDIR/"LOG_"$LDate".log"
				COUNTERLOGT=10
				echo $COUNTERLOGT > $MISCDIR/"COUNTER_DONOTDELETE"
			else 
				((COUNTERLOGT=COUNTERLOGT+5))
				echo $COUNTERLOGT > $MISCDIR/"COUNTER_DONOTDELETE"
			fi 
		fi

	}

	STAR () {									# Star / Cosmetic for visual presentation

		echo "#********************************************************************************" 
	}

	HASH () {									# Hash / Cosmetic for visual presentation

		echo "----------------------------------------------------------------------------------" 
	}

	Space () {									# Space / Cosmetic for visual presentation

		echo " " 
	}

	SetProject2 () {								# Search for Valid Project Name	
		
		echo "Searching... Project Name"
			Project_1=$(grep -i $1 $TEMPDIR/"PROJECT_LIST" | awk '{print $1}')
			#ProjectName=$(grep -i $1 $TEMPDIR/"PROJECT_LIST" | awk '{print $2}')
			if [[ $Project_1 == "" ]] ;then
				echo "NOT FOUND... Project : $1"
				Project=""
			else
				Project_ID=$(echo $Project_1 | awk '{print $1}')
				Project_Name=$(grep -i $Project_ID $TEMPDIR/"PROJECT_LIST" | awk '{print $2}')
				echo "Found... Project ID : $Project_ID / Project Name : $Project_Name"
				#PJSON=$PROJECTDIR/$Project_ID".json"
				#PIDJSON=$PROJECTDIR/$Project_Name".json"
				#PJSONB=$PROJECTDIR/$Project_ID"_BASIC.json"
				#PIDJSONB=$PROJECTDIR/$Project_Name"_BASIC.json"
				
				PJSON=$TEMPDIR/$Project_ID".json"
				PIDJSON=$TEMPDIR/$Project_Name".json"
				PJSONB=$TEMPDIR/$Project_ID"_BASIC.json"
				PIDJSONB=$TEMPDIR/$Project_Name"_BASIC.json"
				
				GITPJSON=$PROJECTDIR/$Project_ID".json"
				GITPIDJSON=$PROJECTDIR/$Project_Name".json"
				GITPJSONB=$PROJECTDIR/$Project_ID"_BASIC.json"
				GITPIDJSONB=$PROJECTDIR/$Project_Name"_BASIC.json"
				> $PJSON
				> $PIDJSON
				> $PJSONB
				> $PIDJSONB
			fi
		
	}

	SetProject () {								# Search for Valid Project Name	
		
		echo "Searching... Project Name"
			Project_Name=$(grep -i $1 $TEMPDIR/"PROJECT_LIST" | grep NAME: | awk '{print $NF}') #Project_name
			#ProjectName=$(grep -i $1 $TEMPDIR/"PROJECT_LIST" | awk '{print $2}')
			if [[ $Project_Name == "" ]] ;then
				echo "NOT FOUND... Project : $1"
				Project=""
			else
				#Project_ID=$(echo $Project_Name | awk '{print $1}')
				Project_ID=$(grep -i $Project_Name $TEMPDIR/"PROJECT_LIST" | grep PROJECT_ID: | awk '{print $NF}')
				echo "Found... Project ID : $Project_ID / Project Name : $Project_Name"
				#PJSON=$PROJECTDIR/$Project_ID".json"
				#PIDJSON=$PROJECTDIR/$Project_Name".json"
				#PJSONB=$PROJECTDIR/$Project_ID"_BASIC.json"
				#PIDJSONB=$PROJECTDIR/$Project_Name"_BASIC.json"
				
				PJSON=$TEMPDIR/$Project_ID".json"
				PIDJSON=$TEMPDIR/$Project_Name".json"
				PJSONB=$TEMPDIR/$Project_ID"_BASIC.json"
				PIDJSONB=$TEMPDIR/$Project_Name"_BASIC.json"
				
				GITPJSON=$PROJECTDIR/$Project_ID".json"
				GITPIDJSON=$PROJECTDIR/$Project_Name".json"
				GITPJSONB=$PROJECTDIR/$Project_ID"_BASIC.json"
				GITPIDJSONB=$PROJECTDIR/$Project_Name"_BASIC.json"
				> $PJSON
				> $PIDJSON
				> $PJSONB
				> $PIDJSONB
			fi
		
	}

	AncestorsInfo () {							# Collects all Ancestore information
		
		#echo "Fetching... Ancestors Information"
		Proca="324064543929"
		Proeu="830060092519"
		Progl="386729001618"
		Prous="734490111662"
		
		Devca="156169603461"
		Deveu="626261954570"
		Devgl="722615396349"
		Devus="141854279533"
		
		Shaca="312924942046"
		Shaeu="600946191269"
		Shagl="334452057043"
		Shaus="482858253667"
		

		gcloud projects get-ancestors $Project_ID  --format="csv[no-heading](id)" | tail -n +2 > $TEMPDIR/"AncestorInfo"
		
		for projloc in $(cat $TEMPDIR/"AncestorInfo")
		do
			if [[ $projloc == $Proca ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_PRO
			TFLOCATION="USPROD"
			fi
			if [[ $projloc == $Proeu ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_EU_PRO	#CORRECT
			TFLOCATION="EUPROD"
			fi
			if [[ $projloc == $Progl ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_PRO
			TFLOCATION="USPROD"
			fi
			if [[ $projloc == $Prous ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_PRO	#CORRECT
			TFLOCATION="USPROD"
			fi

			if [[ $projloc == $Devca ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_DEV
			TFLOCATION="USNONPROD"
			fi
			if [[ $projloc == $Deveu ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_EU_DEV	#CORRECT
			TFLOCATION="EUNONPROD"
			fi
			if [[ $projloc == $Devgl ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_DEV
			TFLOCATION="USNONPROD"
			fi
			if [[ $projloc == $Devus ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_DEV	#CORRECT
			TFLOCATION="USNONPROD"
			fi

			if [[ $projloc == $Shaca ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_DEV
			TFLOCATION="USNONPROD"
			fi
			if [[ $projloc == $Shaeu ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_EU_DEV
			TFLOCATION="EUNONPROD"
			fi
			if [[ $projloc == $Shagl ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_DEV
			TFLOCATION="USNONPROD"
			fi
			if [[ $projloc == $Shaus ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_DEV
			TFLOCATION="USNONPROD"
			fi
			
		done
		
		TFVAR=$GITPARENTDIR/"terraform_"$TFLOCATION".tfvars"
		TFVAR_TEMP=$TEMPDIR/"terraform_"$TFLOCATION".tfvars"
		
	}

	AncestorsInfo_withoutfor () {				# Collects all Ancestore information / Not Used
		
		#echo "Fetching... Ancestors Information"
		Proca="324064543929"
		Proeu="830060092519"
		Progl="386729001618"
		Prous="734490111662"
		
		Devca="156169603461"
		Deveu="626261954570"
		Devgl="722615396349"
		Devus="141854279533"
		
		Shaca="312924942046"
		Shaeu="600946191269"
		Shagl="334452057043"
		Shaus="482858253667"
		
		#PARENT_PROJECT_US_DEV="cops-cloudmonus-nonprod-563b"
		#PARENT_PROJECT_US_PRO="cops-cloudmonus-prod-b71c"
		#PARENT_PROJECT_EU_DEV="cops-cloudmoneu-nonprod-19c7"
		#PARENT_PROJECT_EU_PRO="cops-cloudmoneu-prod-d790"
		
		#PARENT_PROJECT_CA_PRO="CA_PRO"
		#PARENT_PROJECT_EU_PRO="EU_PRO"
		#PARENT_PROJECT_GL_PRO="GL_PRO"
		#PARENT_PROJECT_US_PRO="US_PRO"
		#PARENT_PROJECT_CA_DEV="CA_DEV"
		#PARENT_PROJECT_EU_DEV="EU_DEV"
		#PARENT_PROJECT_GL_DEV="GL_DEV"
		#PARENT_PROJECT_US_DEV="US_DEV"
		#PARENT_PROJECT_CA_SHA="CA_SHA"
		#PARENT_PROJECT_EU_SHA="EU_SHA"
		#PARENT_PROJECT_GL_SHA="GL_SHA"
		#PARENT_PROJECT_US_SHA="US_SHA"
		
		projloc=$(gcloud projects get-ancestors $Project_ID  --format="csv[no-heading](id)" | tail -n +3 | head -n 1 ) 
		#gcloud projects get-ancestors $Project_ID  --format="csv[no-heading](id)" | tail -n +2 > $TEMPDIR/"AncestorInfo"
		
		#for projloc in $(cat $TEMPDIR/"AncestorInfo")
		#do
			if [[ $projloc == $Proca ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_PRO
			fi
			if [[ $projloc == $Proeu ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_EU_PRO	#CORRECT
			fi
			if [[ $projloc == $Progl ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_PRO
			fi
			if [[ $projloc == $Prous ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_PRO	#CORRECT
			fi

			if [[ $projloc == $Devca ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_DEV
			fi
			if [[ $projloc == $Deveu ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_EU_DEV	#CORRECT
			fi
			if [[ $projloc == $Devgl ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_DEV
			fi
			if [[ $projloc == $Devus ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_DEV	#CORRECT
			fi

			if [[ $projloc == $Shaca ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_DEV
			fi
			if [[ $projloc == $Shaeu ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_EU_DEV
			fi
			if [[ $projloc == $Shagl ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_DEV
			fi
			if [[ $projloc == $Shaus ]]; then
			PARENT_PROJECT_ID=$PARENT_PROJECT_US_DEV
			fi
			
		#done
		
	}

	FetchDashBoardID_API ()	{					# Fetch DashBoard Information via API

	#ENTIRE CUSTOM DASHBOARD
	#FETCH DASHBOARD all Custom DAShboard
	echo "Fetching All Dashboard"
	curl -H "Authorization: Bearer $ACCESS_TOKEN" https://monitoring.googleapis.com/v1/projects/${TEMPLATE_PROJECT_ID}/dashboards > $TEMPDIR/"TEMP_DASHBOARD"
	#Fetch DASHBOARD ID
	cat $TEMPDIR/"TEMP_DASHBOARD" | grep -i '"name"' | awk -F'"' '{print $(NF-1)}' | awk -F/ '{print $NF}' > $TEMPDIR/"TEMP_DASHBOARD_ID"
	#echo "DashBoard ID : "
	#cat $TEMPDIR/"TEMP_DASHBOARD_ID"
	
	}
	
	Fetchtemplate_API () {						# Fetach Dashboard teamplate & convert tham into generic Wdiets
	
	cd $TEMPLATEDIR
	rm *
	cd $WIDGETDIR
	rm *
	cd $PROJECTDIR
	rm *
	cd $WORKINGDIR
	for DASHBOARD_ID in $(cat $TEMPDIR/"TEMP_DASHBOARD_ID")
	do
	####
		curl -H "Authorization: Bearer $ACCESS_TOKEN" https://monitoring.googleapis.com/v1/projects/${TEMPLATE_PROJECT_ID}/dashboards/${DASHBOARD_ID} >  $TEMPDIR/"TEMP_DASHBOARD_TEMPLATE"
		TEMPLATE_NAME=$(grep -i displayname $TEMPDIR/"TEMP_DASHBOARD_TEMPLATE" | awk -F'"' '{print $(NF-1)}' | awk '{print $1'}) 
		#echo "Template name : $TEMPLATE_NAME"
		cat $TEMPDIR/"TEMP_DASHBOARD_TEMPLATE" | grep -v '"name": "projects' | grep -v '"etag":' > $TEMPLATEDIR/$TEMPLATE_NAME
		sed -i "s/$TEMPLATE_PROJECT_ID/$TEMP_ID/g" $TEMPLATEDIR/$TEMPLATE_NAME
		cat $TEMPLATEDIR/$TEMPLATE_NAME | tail -n +6 | head -n -4 > $WIDGETDIR/$TEMPLATE_NAME
		echo "Widget Name : $WIDGETDIR/$TEMPLATE_NAME"
	done
	#REMEMBER } / },
	}
		
	Json_Start () {								# Start Json 
	
	echo '{' > $PJSON	
	echo '"displayName": "XXXX-XXXX-XXXX-XXXX",' >> $PJSON		
	echo '"gridLayout": {' >> $PJSON
    echo '"columns": "3",' >> $PJSON
    echo '"widgets": [' >> $PJSON	
	
	echo '{' > $PJSONB
	echo '"displayName": "XXXX-XXXX-XXXX-XXXX",' >> $PJSONB
	echo '"gridLayout": {' >> $PJSONB
    echo '"columns": "3",' >> $PJSONB
    echo '"widgets": [' >> $PJSONB
	
	}
	
	Json_End () {								# End Json
	
	echo '    ]	' >> $PIDJSON
	echo '	}	' >> $PIDJSON
	echo '}		' >> $PIDJSON
	
	echo '    ]	' >> $PIDJSONB
	echo '	}	' >> $PIDJSONB
	echo '}		' >> $PIDJSONB
	}
	
	Widget_End () {								# End Widget	
	echo '      },' >> $PJSON
	echo '      },' >> $PJSONB
	
	}
	
	Widget_End_Final () {						# End EOF Widget
	
	cat $PJSON | head -n -1 > $PIDJSON
	sed -i "s/$TEMP_ID/$Project_ID/g" $PIDJSON
	sed -i "s/$TEMPLATE_PROJECT_ID/$Project_ID/g" $PIDJSON
	rm $PJSON
	echo '      }' >> $PIDJSON
	
	cat $PJSONB | head -n -1 > $PIDJSONB
	sed -i "s/XXXX-XXXX-XXXX-XXXX/$Project_ID/g" $PIDJSONB
	sed -i "s/$TEMPLATE_PROJECT_ID/$Project_ID/g" $PIDJSONB
	rm $PJSONB
	echo '      }' >> $PIDJSONB
	
	}

	Remove_SC_File () {							# Remove Service_Check File
	
	rm $TEMPDIR/$Project_ID"_Service_Check"
	
	}

	Service_Check () {							# Responsible to add Wdigets
	
		if [[ $2 == "0" ]] ; then
			SC_ABC=$2
			if [[ $(cat $TEMPDIR/$Project_ID"_Service_Check" | tail -n +2 ) != "" ]] ; then
				SC_ABC=1
				cat $WIDGETDIR/$1 >> $PJSON
				cat $WIDGETDIR/$1"_BASIC" >> $PJSONB
				W_COUNT=$(grep -i title $WIDGETDIR/$1 | wc -l)
				W_COUNTB=$(grep -i title $WIDGETDIR/$1"_BASIC" | wc -l)
				echo "Total Widget in $1 :" $W_COUNT" / "$1"_BASIC : "$W_COUNTB
				Widget_End
				Remove_SC_File
			else
				SC_ABC=0
			fi
			#echo "Service_Check:"$SC_ABC
			return $SC_ABC
		else
			SC_ABC=$2
			if [[ $(cat $TEMPDIR/$Project_ID"_Service_Check" | tail -n +2 ) != "" ]] ; then
				SC_ABC=1
				cat $WIDGETDIR/$1 >> $PJSON
				cat $WIDGETDIR/$1 >> $PJSONB
				W_COUNT=$(grep -i title $WIDGETDIR/$1 | wc -l)
				echo "Total Widget in $1 :" $W_COUNT
				Widget_End
				Remove_SC_File
			else
				SC_ABC=0
			fi
			#echo "Service_Check:"$SC_ABC
			return $SC_ABC
		fi
	
		
	}

	APP_ENGINE () {								# Check App Service				

			if [[ $(grep -i "appengine.googleapis.com" $TEMPDIR/$Project_ID"_GCP_Services" ) == "appengine.googleapis.com" ]] || [[ $(grep -i "appengineflex.googleapis.com" $TEMPDIR/$Project_ID"_GCP_Services" ) == "appengineflex.googleapis.com" ]] ; then
				echo "Checking... App Information"
				gcloud app services  list --project=$Project_ID > $TEMPDIR/$Project_ID"_Service_Check"
				Service_Check $APP_ENGINE_WIDGETNAME $1
				APP_E=$?
			fi
	}

	VM_INSTANCE () {							# Check Compute Service

			if [[ $(grep -i "compute.googleapis.com" $TEMPDIR/$Project_ID"_GCP_Services" ) == "compute.googleapis.com" ]] ; then
				echo "Checking... Instance Information"
				gcloud compute instances list --project=$Project_ID  > $TEMPDIR/$Project_ID"_Service_Check"
				Service_Check $VM_INSTANCE_WIDGETNAME $1
				VM_I=$?
			fi
	}

	INTERNAL_LOADBALANCER_INPROGRESS () {		# NOTUSED / Collect information on internal load balancer 

		#5 Column
		echo "Checking... LoadBalancer Information"
		gcloud compute forwarding-rules list --project=$Project_ID | tail -n +2 | awk '{print $NF}' > $TEMPDIR/$Project_ID"_Service_Check"
		Service_Check $INTERNAL_LOADBALANCER_WIDGETNAME
	}
	
	INTERNAL_LOADBALANCER () {					# Check Internal Loadbalancer Service
		
			if [[ $(grep -i "compute.googleapis.com" $TEMPDIR/$Project_ID"_GCP_Services" ) == "compute.googleapis.com" ]] ; then
				echo "Checking... LoadBalancer Information"
				gcloud compute forwarding-rules list --project=$Project_ID > $TEMPDIR/$Project_ID"_Service_Check"
				Service_Check $INTERNAL_LOADBALANCER_WIDGETNAME $1
				INTERNAL_L=$?
			fi
	}
	
	INTERNAL_LOADBALANCER_API () {				# NOTUSED / Collect information on internal load balancer 

		#5 Column
		echo "Checking... LoadBalancer Information"
		curl -H "Authorization: Bearer $ACCESS_TOKEN" https://compute.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/addresses
		#gcloud compute forwarding-rules list --project=$Project_ID > $TEMPDIR/$Project_ID"_Service_Check"
		Service_Check $INTERNAL_LOADBALANCER_WIDGETNAME
	}

	CLOUD_STORAGE () {							# Check Cloud Storage Service
	
			if [[ $(grep -i "storage-component.googleapis.com" $TEMPDIR/$Project_ID"_GCP_Services" ) == "storage-component.googleapis.com" ]] ; then
				echo "Checking... Cloud Storage Information"
				gsutil ls -p $Project_ID > $TEMPDIR/$Project_ID"_Service_Check"
				Service_Check $CLOUD_STORAGE_WIDGETNAME $1
				CLOUD_S=$?
			fi
	}

	CLOUD_SQL () {								# Check SQL Service

			if [[ $(grep -i "sqladmin.googleapis.com" $TEMPDIR/$Project_ID"_GCP_Services" ) == "sqladmin.googleapis.com" ]] || [[ $(grep -i "sql-component.googleapis.com" $TEMPDIR/$Project_ID"_GCP_Services" ) == "sql-component.googleapis.com" ]]; then
				echo "Checking... Cloud SQL Information"
				gcloud sql instances list --project=$Project_ID > $TEMPDIR/$Project_ID"_Service_Check"
				Service_Check $CLOUD_SQL_WIDGETNAME $1
				CLOUD_SQL=$?
			fi
	}
	
	CLOUD_SQL_API () {							# NOTUSED / Collects Cloud SQL information
		if [[ $(grep -i "sqladmin.googleapis.com" $TEMPDIR/$Project_ID"_GCP_Services" ) == "sqladmin.googleapis.com" ]] || [[ $(grep -i "sql-component.googleapis.com" $TEMPDIR/$Project_ID"_GCP_Services" ) == "sql-component.googleapis.com" ]]; then
			echo "Checking... Cloud SQL Information"
			curl -H "Authorization: Bearer $ACCESS_TOKEN" https://www.googleapis.com/sql/v1beta4/projects/${PROJECT_ID}/instances > $TEMPDIR/$Project_ID"_Service_Check"
			MYSQL=$(cat $TEMPDIR/$Project_ID"_Service_Check" | jq '.items[] .databaseVersion' | grep MYSQL | uniq | awk -F_ '{print $1}' | awk -F'"' '{print $NF}')
			POSTGRES=$(cat $TEMPDIR/$Project_ID"_Service_Check" | jq '.items[] .databaseVersion' | grep POSTGRES | uniq | awk -F_ '{print $1}' | awk -F'"' '{print $NF}')
			if [[ $(echo $MYSQL) ==  "MYSQL" ]] || [[ $(echo $POSTGRES) ==  "POSTGRES" ]] ; then
				Service_Check $CLOUD_SQL_WIDGETNAME
					if [[ $(echo $MYSQL) ==  "MYSQL" ]] ; then
						FLAGA=0
						Service_Check $CLOUD_MYSQL_WIDGETNAME $1
						#CLOUD_MSQL=$?
					fi
		
					if [[ $(echo $POSTGRES) ==  "POSTGRES" ]] ; then
						FLAGA=0
						Service_Check $CLOUD_POSTGRES_WIDGETNAME $1
						#CLOUD_PSQL=$?
					fi
			fi
		fi
	}

	CLOUD_PUBSUB () {							# Check PUBSUB Service
	
			if [[ $(grep -i "pubsub.googleapis.com" $TEMPDIR/$Project_ID"_GCP_Services" ) == "pubsub.googleapis.com" ]] ; then
				echo "Checking... PubSub Information"
				gcloud pubsub topics list --project=$Project_ID > $TEMPDIR/$Project_ID"_Service_Check"
				Service_Check $CLOUD_PUBSUB_WIDGETNAME $1
				CLOUD_PS=$?
			fi
	}

	CLOUD_FUNCTION () {							# Check Cloud Function Service

			if [[ $(grep -i "cloudfunctions.googleapis.com" $TEMPDIR/$Project_ID"_GCP_Services" ) == "cloudfunctions.googleapis.com" ]] ; then
				echo "Checking... Functions Information"
				gcloud functions list --project=$Project_ID > $TEMPDIR/$Project_ID"_Service_Check"
				Service_Check $CLOUD_FUNCTIONS_WIDGETNAME $1			
				CLOUD_F=$?
			fi
	}
	
	CLOUD_DATAPROC () {							# Check Dataproc Service

			if [[ $(grep -i "dataproc.googleapis.com" $TEMPDIR/$Project_ID"_GCP_Services" ) == "dataproc.googleapis.com" ]] ; then
				echo "Checking... Dataproc Information"
				#> $TEMPDIR/$Project_ID"DATAPROC_Service_Check"
				#for m in "${REGION[@]}"
				#do
				#	curl -H "Authorization: Bearer $ACCESS_TOKEN" https://dataproc.googleapis.com/v1/projects/${PROJECT_ID}/regions/$m/clusters #> $TEMPDIR/$Project_ID"DATAPROC_Service_Check"
					# do something on $m #
				#done
				> $TEMPDIR/$Project_ID"_Service_Check"
				for m in "${REGION[@]}"
				do
				gcloud dataproc clusters list --region=$m --project=$Project_ID >> $TEMPDIR/$Project_ID"_Service_Check"
				done
				
				Service_Check $CLOUD_DATAPROC_WIDGETNAME $1			
				CLOUD_DP=$?
			fi
	}
	
	GKE_CLUSTER () {							# Check GKE Service
	
		if [[ $(grep -i "container.googleapis.com" $TEMPDIR/$Project_ID"_GCP_Services" ) == "container.googleapis.com" ]] ; then
			echo "Checking... GKE Information"
			#> $TEMPDIR/$Project_ID"DATAPROC_Service_Check"
			#for m in "${REGION[@]}"
			#do
			#	curl -H "Authorization: Bearer $ACCESS_TOKEN" https://dataproc.googleapis.com/v1/projects/${PROJECT_ID}/regions/$m/clusters #> $TEMPDIR/$Project_ID"DATAPROC_Service_Check"
				# do something on $m #
			#done
			#> $TEMPDIR/$Project_ID"_Service_Check"
			#for m in "${REGION[@]}"
			#do
			gcloud container clusters list --region=$m --project=$Project_ID > $TEMPDIR/$Project_ID"_Service_Check"
			#done
			
			Service_Check $GKE_CLUSTER_WIDGETNAME $1			
			GKE_C=$?
		fi
	}
	
	BIG_QUERY () {								# NOTUSED / NEED TO BE WORKED developed module
	
	if [[ $(grep -i "bigquery.googleapis.com" $TEMPDIR/$Project_ID"_GCP_Services" ) == "bigquery.googleapis.com" ]] ; then
		echo "Checking... Big Query Information"
		bq ls --project_id $Project_ID > $TEMPDIR/$Project_ID"_Service_Check"
		
		Service_Check $BIG_QUERY_WIDGETNAME $1			
		BIG_Q=$?
	fi
	}
	
	CLOUD_RUN () {								# Check Cloud Run Service
	
	if [[ $(grep -i "run.googleapis.com" $TEMPDIR/$Project_ID"_GCP_Services" ) == "run.googleapis.com" ]] ; then
		echo "Checking... Cloud Run Information"
		gcloud run services list --platform managed --project=$Project_ID > $TEMPDIR/$Project_ID"_Service_Check"
		Service_Check $CLOUD_RUN_WIDGETNAME $1			
		CLOUD_R=$?
	fi
	
	}
	
	ADHOC_WIDGET () {							# Used if you want to add Addhoc dashboard / special customization
			
			if [[ $(ls -l $WIDGETDIR | tail -n +2 | awk '{print $NF}' | grep -iw $1 ) == $1 ]] ; then
				echo "Adding... $1 Widget as per your request "
				cat $WIDGETDIR/$1 > $TEMPDIR/$Project_ID"_Service_Check"
				AWID=1
				Service_Check $1 $AWID
				ADHOC_W=$?
			fi
	}
	
	OUTPUT () {									# Check Widget in dashboard below 25
	
				#GITPJSON=$PROJECTDIR/$Project_ID".json"
				#GITPIDJSON=$PROJECTDIR/$Project_Name".json"
				#GITPJSONB=$PROJECTDIR/$Project_ID"_BASIC.json"
				#GITPIDJSONB=$PROJECTDIR/$Project_Name"_BASIC.json"
	
	
	
	WID_COUNT=$(grep -i title $PIDJSON | wc -l)
	WID_COUNTB=$(grep -i title $PIDJSONB | wc -l)
		if [[ $WID_COUNT -ge "25" ]] ; then 
			STAR
			STAR
			echo "Total Number of Widgets = $WID_COUNT  "
			echo "Which is higher than dashbaord widget limit of 25, you wont be able to use it."
			echo "Initiating trim down version & implementing basic templates"
			rm $PIDJSON
			STAR
			cat $PIDJSONB > $GITPIDJSONB
			echo "File Location : "$GITPIDJSONB
			echo "Count : "$WID_COUNTB" : Location : "$TFLOCATION" : Project : "$Project_ID" : Location :"$GITPIDJSONB >> $PROJSON
			WID_COUNT=$( grep -i title $GITPIDJSONB | wc -l)
			echo "Total Number of Widgets = $WID_COUNT"
			BASICFLAG=1
			Terraform_File $BASICFLAG
			STAR
		else
			if [[ $WID_COUNT == "0" ]] ; then 
				STAR
				echo "Nothing to monitor in $Project_ID"
				rm $PIDJSON
				rm $PIDJSONB
				echo "Count : "$WID_COUNT" : Location : "$TFLOCATION" : Project : "$Project_ID" : Location : N/A" >> $PROJSON
				STAR
			else 
				if [[ $WID_COUNTB -ge "25" ]] ; then
					echo "Count : "$WID_COUNTB" : Location : "$TFLOCATION" : Project : "$Project_ID" : ERROR : Basic Dashboard higher than 25, manual intervention needed" >> $PROJSON
					rm $PIDJSON
					rm $PIDJSONB
				else
					STAR
					cat $PIDJSON > $GITPIDJSON
					echo "File Location : "$GITPIDJSON
					echo "Total Number of Widgets = $WID_COUNT"
					echo "Count : "$WID_COUNT" : Location : "$TFLOCATION" : Project : "$Project_ID" : Location :"$GITPIDJSON >> $PROJSON
					BASICFLAG=0
					Terraform_File $BASICFLAG
					rm $PIDJSONB
					STAR
				fi
			fi
		fi
		#echo "Count : "$WID_COUNT" : Project : "$Project_ID >> $PROJSON
	}

	OUTPUT2 () {								# NOTUSED / Check Widget in dashboard below 25
	
				#GITPJSON=$PROJECTDIR/$Project_ID".json"
				#GITPIDJSON=$PROJECTDIR/$Project_Name".json"
				#GITPJSONB=$PROJECTDIR/$Project_ID"_BASIC.json"
				#GITPIDJSONB=$PROJECTDIR/$Project_Name"_BASIC.json"
	
	
	
	WID_COUNT=$(grep -i title $PIDJSON | wc -l)
	WID_COUNTB=$(grep -i title $PIDJSONB | wc -l)
		if [[ $WID_COUNT -ge "25" ]] ; then 
			STAR
			STAR
			echo "Total Number of Widgets = $WID_COUNT  "
			echo "Which is higher than dashbaord widget limit of 25, you wont be able to use it."
			echo "Initiating trim down version & implementing basic templates"
			rm $PIDJSON
			STAR
			#cat $PIDJSONB > $GITPJSONB
			echo "File Location : "$PIDJSONB
			echo "Count : "$WID_COUNTB" : Project : "$Project_ID" : Location :"$PIDJSONB >> $PROJSON
			WID_COUNT=$(grep -i title $PIDJSONB | wc -l)
			echo "Total Number of Widgets = $WID_COUNT"
			BASICFLAG=1
			Terraform_File $BASICFLAG
			STAR
		else
			if [[ $WID_COUNT == "0" ]] ; then 
				STAR
				echo "Nothing to monitor in $Project_ID"
				rm $PIDJSON
				rm $PIDJSONB
				echo "Count : "$WID_COUNT" : Project : "$Project_ID" : Location : N/A" >> $PROJSON
				STAR
			else 
				if [[ $WID_COUNTB -ge "25" ]] ; then
					echo "Count : "$WID_COUNTB" : Project : "$Project_ID" : ERROR : Basic Dashboard higher than 25, manual intervention needed" >> $PROJSON
					rm $PIDJSON
					rm $PIDJSONB
				else
					STAR
					echo "File Location : "$PIDJSON
					echo "Total Number of Widgets = $WID_COUNT"
					echo "Count : "$WID_COUNT" : Project : "$Project_ID" : Location :"$PIDJSON >> $PROJSON
					BASICFLAG=0
					Terraform_File $BASICFLAG
					rm $PIDJSONB
					STAR
				fi
			fi
		fi
		#echo "Count : "$WID_COUNT" : Project : "$Project_ID >> $PROJSON
	}

	GITHUB_DOWNLOAD () {						# Download repo
	
	if [  -d $GITHUBDIR ]; then	
		rm -rf $GITHUBDIR
	fi
	mkdir $GITHUBDIR
	echo "Downloading from GITHUB "
	cd $GITHUBDIR
	git clone git@github.com:mckesson/core-gcp-stackdriver-monitoring.git
	cd $WORKINGDIR
	echo "Download Done"
	
	##gsutil -m cp $GITPARENTDIR/*.tfvars gs://$Bucket/terraform_variable_backup/
	
	}
	
	GITHUB_COPY () {							# Copy to repo/Bucket/Backup_Bucket
			
	cp $PROJECTDIR/* $GITCODEDIR/json_project/	
	cp $TEMPLATEDIR/* $GITCODEDIR/json_template/
	cp $WIDGETDIR/* $GITCODEDIR/json_widget/
	
	
	
	#gsutil cp -D gs://$Bucket/json_project/* gs://$Bucket/json_project_BACKUP
	#gsutil cp -D gs://$Bucket/json_template/* gs://$Bucket/json_template_BACKUP
	#gsutil cp -D gs://$Bucket/json_widget/* gs://$Bucket/json_widget_BACKUP

	
	gsutil -m cp $PROJECTDIR/* gs://$Bucket/json_project
	gsutil -m cp $TEMPLATEDIR/* gs://$Bucket/json_template
	gsutil -m cp $WIDGETDIR/* gs://$Bucket/json_widget
	

	
	}
	
	GITHUB_UPLOAD () {							# Upload repo & merge to develop to master
	
	echo "Uploading to GITHUB "
	cd $GITPARENTDIR
	git branch
	git checkout -b "feature/Automated_dashboard"
	git branch
	git add -A
	git commit -am "Updating DashBoard Json File via ShellScript $Version"
	git push origin feature/Automated_dashboard
	
	echo "Upload Done"
	
	#this looks good
	echo "Merging to Develop "
	git branch
	git checkout "develop"
	git branch
	git merge "feature/Automated_dashboard"
	git push origin "develop"
	echo "Done"
	
	echo "Merging to Master "
	git checkout "master"
	git branch
	git merge "develop"
	git push origin "master"
	cd $WORKINGDIR
	echo "Done"
	
	}
		
	GIT_Json_Replace () {						# NOTUSED 
	
	GITJSON=$(ls -l $GITCODEDIR/json_template | awk '{print $NF}' | tail -n +2 | grep -i $Project_Name )
	
	if [[ $GITJSON != "" ]]; then
		if [[ $GITJSON == $Project_Name".json" ]]  && [[ $1 == 1 ]] ; then
		rm $GITCODEDIR/json_project/$Project_Name".json"
		fi
		
		if [[ $GITJSON == $Project_Name"_BASIC.json" ]] && [[ $1 == 0 ]]; then
		rm $GITCODEDIR/json_project/$Project_Name"_BASIC.json"
		fi
	fi
	}	
		
	Terraform_File () {							# Make changes to Terraform.TFvars

	#Backup of tarraform.tfvars
	gsutil -m cp $TFVAR gs://$Bucket/terraform_variable_backup/
	TFV=$(cat $TFVAR | grep dashboard_json_file  | grep -i $Project_Name | awk -F/ '{print $NF}' | awk -F'"' '{print $1}')
	#OR
	GITJSON=$(ls -l $GITCODEDIR/json_template | awk '{print $NF}' | tail -n +2 | grep -i $Project_Name )

		SEDPRO=$(echo $Project_Name'.json')
		SEDPROB=$(echo $Project_Name'_BASIC.json')
		TFLOC=$(echo './dashboards/json_project/'$SEDPRO)
		TFLOCB=$(echo './dashboards/json_project/'$SEDPROB)
		

	if [[ $TFV == "" ]]; then
		#AncestorsInfo
		cat $TFVAR | head -n -2 > $TFVAR_TEMP
		echo "   }," >> $TFVAR_TEMP
		echo '   dashboard_'$Project_Name' = {' >> $TFVAR_TEMP
		echo '      project_id = "'$PARENT_PROJECT_ID'"' >> $TFVAR_TEMP
		
		if [[ $1 == 1 ]] ; then 
			echo '      dashboard_json_file = "'$TFLOCB'"' >> $TFVAR_TEMP
		fi
		if [[ $1 == 0 ]] ; then 
			echo '      dashboard_json_file = "'$TFLOC'"' >> $TFVAR_TEMP
		fi
		cat $TFVAR_TEMP > $TFVAR
		echo "   }" >> $TFVAR
		echo "}" >> $TFVAR
	else
		if [[ $TFV == $Project_Name".json" ]]  && [[ $1 == 1 ]] ; then	#BASIC
			sed -i "s/$SEDPRO/$SEDPROB/g" $TFVAR
		fi
		
		if [[ $TFV == $Project_Name"_BASIC.json" ]] && [[ $1 == 0 ]] ; then #NOBASIC
			sed -i "s/$SEDPROB/$SEDPRO/g" $TFVAR
		fi		

		if [[ $GITJSON != "" ]]; then
			if [[ $GITJSON == $Project_Name".json" ]]  && [[ $1 == 1 ]] ; then
				rm $GITCODEDIR/json_project/$Project_Name".json"
			fi
			
			if [[ $GITJSON == $Project_Name"_BASIC.json" ]] && [[ $1 == 0 ]] ; then
				rm $GITCODEDIR/json_project/$Project_Name"_BASIC.json"
			fi
		fi
	fi
	
	#TFVAR/TFVAR_TEMP/TFVAR_SMALL
	}

	Terraform_Pre_Backup () {					# NOTUSED 

	gsutil -m cp $GITPARENTDIR/*.tfvars gs://$Bucket/terraform_variable_backup/
	
	#-auto-approve 
	}

	GCPService () {								# Collects information on which API service is enable

	echo "Fetching... GCP Enabled Service Information"
	gcloud services list --project=$Project_ID --format="csv(NAME)" > $TEMPDIR/$Project_ID"_GCP_Services"
		
	}

	WhiteList () {								# Record special needs of project customization

	whitefile=$GITSUPPORTDIR/"whitelist"
	WhiteProject=$(grep -i $Project_ID $whitefile | awk '{print $1}')
	FLAG=$(grep -i $Project_ID $whitefile | awk '{print $2}')
	AD=$(grep -i $Project_ID $whitefile | awk '{print $3}')
	
	if [[ $WhiteProject == "" ]]; then
		if [[ $1 == "1" ]] && [[ $2 != "" ]]; then
			echo $Project_ID" "$1" "$2 >> $whitefile 
		else
			echo $Project_ID >> $whitefile 
		fi
	else
		if [[ $1 == "1" ]] && [[ $2 != "" ]] && [[ $FLAG == "" ]] && [[ $AD == "" ]] ; then
			grep -v $Project_ID $whitefile > $TEMPDIR/"whitefile"
			cat $TEMPDIR/"whitefile" > $whitefile
			echo $Project_ID" "$1" "$2 >> $whitefile
			FLAG=$1
			AD=$2
			ADFLAG=$FLAG
			ADDATA=$AD
		else
			if [[ $FLAG != "" ]] && [[ $AD != "" ]] ; then
				ADFLAG=$FLAG
				ADDATA=$AD
			fi
		fi
	fi
	}
	
	BlackList () {								# Dashboard will no be created, if project is part of blacklist

	#GITSUPPORTDIR #Project_Name
	blackfile=$GITSUPPORTDIR/"blacklist"
	BlackProject=$(grep -i $Project_ID $blackfile | sed -r '/^\s*$/d' | awk '{print $1}')
	if [[ $BlackProject == "" ]]; then
	BLACKFLAG="0"
	else
	BLACKFLAG="1"
	fi
	
	}

	Credit () {									# Credit / Version 

	#Space
	#Space
	echo "####,####,####,####,####"  #>> $OUTPUTCSV
	echo "Script created by :,Prasanchandra Lakhani" # >> $OUTPUTCSV
	echo "Email:, prasanchandra.lakhani@atos.net"  #>> $OUTPUTCSV
	echo "Script Version:, $Version" #>> $OUTPUTCSV
	echo "####,####,####,####,####"  #>> $OUTPUTCSV

}

	Stack2 () {									# Main Module
		
		ADFLAG=$2
		ADDATA=$3
		SetProject "$1"
		BlackList
		WhiteList "$ADFLAG" "$ADDATA"
		if [[ $Project_ID != "" ]] && [[ $BLACKFLAG == "0" ]] && [[ $Project_Name != $ADDATA ]] ; then
			#WhiteList "$ADFLAG" "$ADDATA"
			AncestorsInfo
			GCPService
			Json_Start
			#***********************
			#FronEnd Service
			APP_ENGINE "$SC_FLAG"
			VM_INSTANCE "$SC_FLAG"
			#InBetween Service
			INTERNAL_LOADBALANCER "$SC_FLAG"
			GKE_CLUSTER "$SC_FLAG"
			CLOUD_FUNCTION "$SC_FLAG"
			CLOUD_PUBSUB "$SC_FLAG"
			CLOUD_DATAPROC "$SC_FLAG"
			CLOUD_RUN "$SC_FLAG"
			#BackEndService
			CLOUD_STORAGE "$SC_FLAG"
			CLOUD_SQL "$SC_FLAG"
			#**********************
			if [[ $ADFLAG == "1" ]]; then
				ADHOC_WIDGET "$ADDATA"
			fi
			Widget_End_Final
			Json_End
			OUTPUT
			#Terraform_File
		else
			if [[ $Project_ID != "" ]] && [[ $BLACKFLAG == "1" ]] ; then
				echo "Project : "$Project_ID" BLACK LISTED"
			else
				if [[ $Project_ID != "" ]] && [[ $Project_Name == $ADDATA ]] ; then
					if [[ $ADFLAG == "1" ]]; then
						#WhiteList "$ADFLAG" "$ADDATA"
						AncestorsInfo
						GCPService
						Json_Start
						ADHOC_WIDGET "$ADDATA"
						Widget_End_Final
						Json_End
						OUTPUT
					fi
				fi
			fi
		fi
		
		
	}

	Stack () {									# Main Module
		
		ADFLAG=$2
		ADDATA=$3
		SetProject "$1"
		BlackList
		WhiteList "$ADFLAG" "$ADDATA"
		if [[ $Project_ID != "" ]] && [[ $BLACKFLAG == "0" ]] && [[ $Project_Name != $ADDATA ]] ; then
			#WhiteList "$ADFLAG" "$ADDATA"
			AncestorsInfo
			GCPService
			Json_Start
			#***********************
			#FronEnd Service
			APP_ENGINE "$SC_FLAG"
			VM_INSTANCE "$SC_FLAG"
			#InBetween Service
			INTERNAL_LOADBALANCER "$SC_FLAG"
			GKE_CLUSTER "$SC_FLAG"
			CLOUD_FUNCTION "$SC_FLAG"
			CLOUD_PUBSUB "$SC_FLAG"
			CLOUD_DATAPROC "$SC_FLAG"
			CLOUD_RUN "$SC_FLAG"
			#BackEndService
			CLOUD_STORAGE "$SC_FLAG"
			CLOUD_SQL "$SC_FLAG"
			#**********************
			if [[ $ADFLAG == "1" ]]; then
				ADHOC_WIDGET "$ADDATA"
			fi
			Widget_End_Final
			Json_End
			OUTPUT
			Terraform_File
		else
			if [[ $Project_ID != "" ]] && [[ $BLACKFLAG == "1" ]] ; then
				echo "Project : "$Project_ID" BLACK LISTED"
			else
				if [[ $Project_ID != "" ]] && [[ $Project_Name == $ADDATA ]] ; then
					if [[ $ADFLAG == "1" ]]; then
						#WhiteList "$ADFLAG" "$ADDATA"
						AncestorsInfo
						GCPService
						Json_Start
						ADHOC_WIDGET "$ADDATA"
						Widget_End_Final
						Json_End
						OUTPUT
					fi
				fi
			fi
		fi
		
		
	}


	Stacktemp () {								# Main TDeveloper Module

		SetProject "$1"
		
		if [[ $Project_ID != "" ]]; then
			AncestorsInfo
			GCPService
			Json_Start
			#***********************
			#FronEnd Service
			APP_ENGINE "$SC_FLAG"
			VM_INSTANCE "$SC_FLAG"
			#InBetween Service
			INTERNAL_LOADBALANCER "$SC_FLAG"
			GKE_CLUSTER "$SC_FLAG"
			CLOUD_FUNCTION "$SC_FLAG"
			CLOUD_PUBSUB "$SC_FLAG"
			CLOUD_DATAPROC "$SC_FLAG"
			#BackEndService
			CLOUD_STORAGE "$SC_FLAG"
			CLOUD_SQL "$SC_FLAG"
			#**********************
			if [[ $2 == "1" ]]; then
				ADHOC_WIDGET "$3"
			fi
			Widget_End_Final
			Json_End
			OUTPUT
			#Terraform_File
			
		fi
		
	}

	main () {									# Execute Stack module based on flag provided 
		
		GITHUB_DOWNLOAD
		gcloud projects list | grep -v PROJECT_NUMBER > $TEMPDIR/"PROJECT_LIST"
		if [[ $1 == "-auto" ]]  ; then
			FetchDashBoardID_API
			Fetchtemplate_API
			cat $TEMPDIR/"PROJECT_LIST" | grep PROJECT_ID | awk '{print $(NF)}' | tail -n +2 > $TEMPDIR/GcpProjectID.txt
			FileLen=$(cat $TEMPDIR/GcpProjectID.txt | sed -r '/^\s*$/d' | wc -l)
			if [[ $FileLen != 0 ]]; then
				SINGLE="N"
				for i in $(cat $TEMPDIR/GcpProjectID.txt | sed -r '/^\s*$/d' )
				do
					STAR
					echo "Remaining Project : "$FileLen
					STAR
					Stack "$i" 
					((FileLen=FileLen-1))
				done
				fi
		else
			Counter
		fi
		if [[ $1 == "-r" ]] || [[ $3 == "-r" ]] ; then
			FetchDashBoardID_API
			Fetchtemplate_API
		fi
		#if [[ $4 != "" ]] ; then
		#	MISC_T=$4
		#	FLAG="1"
		#fi
		if [[ $1 != "-restore" ]] ; then		#NEED TO DEVELOP
			echo ""
		fi
		#******************************************************************************
		if [[ $1 == "-p" ]] && [[ $2 != "" ]] ; then
			if [[ $4 != "" ]]; then
				FLAG="1"
				Stack "$2" "$FLAG" "$4"
			else
			Stack "$2" 
			fi
		fi
		#******************************************************************************
		if [[ $1 == "-ptemp" ]] && [[ $2 != "" ]] ; then
			if [[ $4 != "" ]]; then
				FLAG="1"
				Stacktemp "$2" "$FLAG" "$4"
			else
			Stacktemp "$2" 
			fi
			SINGLE="Y"
			if [[ $Project != "" ]]; then
				Output
			fi
		fi
		#******************************************************************************		
		if [[ $1 == "-f" ]] && [[ $2 != "" ]] ; then
			FileLen=$(cat $2 | sed -r '/^\s*$/d' | wc -l)
			if [[ $FileLen != 0 ]]; then
				SINGLE="N"
				for i in $(cat $2 | awk '{print $1}' | sed -r '/^\s*$/d' )
				do
					MISC_T=$(grep $i $2 | awk '{print $2}')
					
					STAR
					echo "Remaining Project : "$FileLen
					STAR
					STAR
					if [[ $MISC_T == "" ]]; then
						FLAG="0"
						Stack "$i" "$FLAG" 
					else
						FLAG="1"
						Stack "$i" "$FLAG" "$MISC_T"					
					fi
					((FileLen=FileLen-1))
				done
			fi	
		fi
		#******************************************************************************
		if [[ $1 == "-ftemp" ]] && [[ $2 != "" ]] ; then
			FileLen=$(cat $2 | sed -r '/^\s*$/d' | wc -l)
			if [[ $FileLen != 0 ]]; then
				SINGLE="N"
				for i in $(cat $2 | awk '{print $1}' | sed -r '/^\s*$/d'  )
				do
					MISC_T=$(grep $i $2 | awk '{print $2}')
					STAR
					echo "Remaining Project : "$FileLen
					STAR
					STAR
					if [[ $MISC_T == "" ]]; then
						FLAG="0"
						Stacktemp "$i" "$FLAG" 
						
					else
						FLAG="1"
						Stacktemp "$i" "$FLAG" "$MISC_T"
					fi
					((FileLen=FileLen-1))
				done
			fi	
			
		fi
		
		if [[ $1 == "" ]] ; then 
			usage
			exit 1
		fi
		GITHUB_COPY
		GITHUB_UPLOAD
		STAR
		cat $PROJSON | grep -v "Count : 0 : Project :"
		cat $PROJSON | grep "Count : 0 : Project :"
		STAR
	}

	#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	main "$1" "$2" "$3" "$4" | tee -a $LOGTXT				# Main Program & Collects Logs as log file

	rm -r $TEMPDIR								# Clean up temp directory

