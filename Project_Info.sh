#!/bin/bash
	#************************************************************************************************************************************
	# Company    : Atos
	# Created by : Prasan Lakhani 
	# DAS ID 	 : A517965
	# Email ID   : prasanchandra.lakhani@atos.net
	#
	# Desciption : Script automates some steps of project onboarding 
	#
	# Version="11.1" / Redesign Folder Structure  / Add lite version feature / Zip File / Developer version
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
	Version="11.3"
	
	#Function
	usage (){									# Shows how to use the Script

			echo "----------------------------------------------------------------------------------------------------------------"
			echo "Script Created by Prasan Lakhani"
			echo "----------------------------------------------------------------------------------------------------------------"
			echo "run ./Project_Info.sh -p <Project Name>		# To get info for single Service project"    
			echo "run ./Project_Info.sh -s <Project Name>		# To get info for single Standalone project"
			echo "run ./Project_info.sh -f <File_Name>			# To get info from multiple Service Project"
			echo ""
			echo "run ./Project_Info.sh -plite <Project Name>		# To get info for single Service project / Lite version *"  
			echo "run ./Project_info.sh -flite <File_Name>			# To get info from multiple Service Project / Lite version *"
			echo "    * Lite Version will not capture Cloud Storage/IAM/GCPService information"
			echo ""
			echo "cat <File_Name>"
			echo "Project_Name 1"
			echo "Project_Name 2"
			echo "Example :  ./Project_Info.sh -p net-vpc-prod 			#Service Project "
			echo "Example :  ./Project_Info.sh -s retl-lod-prod-a027 	#Standalone Project "
			echo "Example :  ./Project_Info.sh -f Project_list.txt		#List of Service Projects "
			echo "----------------------------------------------------------------------------------------------------------------"
			
	}



	#+++++++++++++++++++++++++++++
	WORKINGDIR=$(pwd)
	OUTPUTDIR=$WORKINGDIR/Output
	TEMPDIR=$OUTPUTDIR/Temp
	LOGDIR=$OUTPUTDIR/LOG
	MISCDIR=$OUTPUTDIR/Misc
	FINALOUTPUT=$OUTPUTDIR/FinalOutput

	#IndidualFile
	LDate=$(date | tr -d ' ')
	OUTPUTCSV2=$MISCDIR/"Project_Info_"$LDate".csv"
	OUTPUTCSVHOST=$MISCDIR/"Host_Info_"$LDate".csv"
	LOGTXT=$LOGDIR/"LOG_"$LDate".log"
	ZIPIT=$FINALOUTPUT/"Zip_"$LDate".zip"
	Bucket=""
	
	


	if [ ! -d $OUTPUTDIR ]; then				# Output Folder Check

		mkdir $OUTPUTDIR
		COUNTERLOGT=10
		echo $COUNTERLOGT > $OUTPUTDIR/"COUNTER_DONOTDELETE"
		
	fi

	if [ ! -d $FINALOUTPUT ]; then				# FinalOutput Folder Check
		
		mkdir $FINALOUTPUT
		
	fi

	if [ -d $TEMPDIR ]; then					# Temp Folder Check
		
		rm -r $TEMPDIR	
		
	fi

	mkdir $TEMPDIR

	if [ ! -d $LOGDIR ]; then					# Log Folder Check
		
		mkdir $LOGDIR
		
	fi

	if [ ! -d $MISCDIR ]; then					# Log Folder Check
		
		mkdir $MISCDIR
		
	fi

	if [ -f $OUTPUTDIR/"COUNTER_DONOTDELETE" ]; then
		COUNTERLOGT=$(cat $OUTPUTDIR/"COUNTER_DONOTDELETE")
	else
		COUNTERLOGT=10
		echo $COUNTERLOGT > $OUTPUTDIR/"COUNTER_DONOTDELETE"
	fi

	> $MISCDIR/"Project_Index.txt"
	> $OUTPUTCSV2
	echo "Application Name,Project Name,Project ID,BAP,Environment,Project Owner,Technical owner,Project Creation Date,GCE Used?,GAE Used?,Core Images Used?,Snapshot Policy Exists?,Snapshots Exists?" >> $OUTPUTCSV2
	> $OUTPUTCSVHOST
	echo "Project ID,name,status,zone,internal_ip,external_ip,bap_number(if any)" > $OUTPUTCSVHOST
	#Define Variables
	FLAG=1

	Counter () {								# Couter for Cleanup
		
		COUNTERZIP=$(ls -l $FINALOUTPUT | grep .zip | wc -l)
		COUNTERCSV=$(ls -l $FINALOUTPUT | grep .csv | wc -l)
		COUNTERLOG=$(ls -l $LOGDIR | grep -i .log | wc -l) 
		COUNTERMIS=$(ls -l $MISCDIR | wc -l ) 
		
		if [[ $COUNTERLOG -ge $COUNTERLOGT ]] ; then
			Star
			Star
			echo "Warning from Prasan Lakhani"
			echo "You have used this Script for $COUNTERLOG times"
			echo "Current Usage 		: "
			echo "Current ZIP File		: $COUNTERZIP 	:  Location : $FINALOUTPUT"
			echo "Current CSV File		: $COUNTERCSV 	:  Location : $FINALOUTPUT"
			echo "Current Misc File		: $COUNTERMIS 	:  Location : $MISCDIR"
			echo "Current LOG File		: $COUNTERLOG 	:  Location : $LOGDIR"
			echo "Do you want to clean the folder ? (Y/y/N/n)"
			echo "If no clean manually"
			Star
			echo "HOPE YOU HAVE DOWNLOADED ALL ZIP FILE"
			Star
			Star
			read REPLY
			if [[ $REPLY == "Y" ]] || [[ $REPLY == "y" ]] ; then
				cd $FINALOUTPUT
				rm *.*
				cd $MISCDIR
				rm *.*
				cd $LOGDIR
				rm *.*
				cd $WORKINGDIR
				LOGTXT=$LOGDIR/"LOG_"$LDate".log"
				COUNTERLOGT=10
				echo $COUNTERLOGT > $OUTPUTDIR/"COUNTER_DONOTDELETE"
			else 
				((COUNTERLOGT=COUNTERLOGT+5))
				echo $COUNTERLOGT > $OUTPUTDIR/"COUNTER_DONOTDELETE"
			fi 
		fi

	}

	Star () {									# Star / Cosmetic for visual presentation

		echo "#********************************************************************************" 
	}

	Hash () {									# Hash / Cosmetic for visual presentation

		echo "----------------------------------------------------------------------------------" 
	}

	Space () {									# Space / Cosmetic for visual presentation

		echo " "  >> $OUTPUTCSV
	}

	SetProject2 () {								# Search for Valid Project Name	
		
		echo "Searching... Project Name"
		if [[ $1 == "" ]] ;then
			Project=$(gcloud info --format='value(config.project)')
			if [[ $Project == "" ]] ;then
				Project="net-vpc-prod-c9a5"
			fi
			echo "Using Current Project : $Project" 
		else
			Project_1=$(gcloud projects list | grep -i $1 | awk '{print $1}')
			ProjectName=$(gcloud projects list | grep -i $1 | awk '{print $2}')
			if [[ $Project_1 == "" ]] ;then
				echo "NOT FOUND... Project Name : $1"
				Project=""

			else
				Project=$(echo $Project_1 | awk '{print $1}')
				echo "Found... Project Name : $Project"
			fi
		fi
		PFLAG=""
		if [[ $2 == "-s" ]] || [[ $Project == "retl-lod-prod-a027" ]] ; then
			PFLAG="sa"
		fi
		
	}
	
	SetProject () {								#Search for Valid Project Name	
		
		echo "Searching... Project Name"
		if [[ $1 == "" ]] ;then
			Project=$(gcloud info --format='value(config.project)')
			if [[ $Project == "" ]] ;then
				Project="net-vpc-prod-c9a5"
			fi
			echo "Using Current Project : $Project" 
		else
			Project_1=$(gcloud projects list | grep -i PROJECT_ID: | grep $1 | awk '{print $2}')
			ProjectName=$(gcloud projects list | grep -i NAME: | grep $1 | awk '{print $2}')
			if [[ $Project_1 == "" ]] ;then
				echo "NOT FOUND... Project Name : $1"
				Project=""
	
			else
				Project=$Project_1
				echo "Found... Project Name : $Project"
			fi
		fi
		PFLAG=""
			if [[ $2 == "-s" ]] || [[ $Project == "retl-lod-prod-a027" ]] ; then
				PFLAG="sa"
			fi
		
	}

	SetFlag () {								# Check if Service project is Prod/Dev/Test and set Host Project accordingly

		FLAG=$(echo $Project | awk -F"-" '{print $(NF-1)}')      
		if [[ $FLAG == "prod" ]] || [[ $FLAG == "usprod" ]] || [[ $FLAG == "euprod" ]] ; then
			FLAG="p"
			Host_Project="net-vpc-prod-c9a5"
			Host_Network="vpc-core-prod"
		else
			if [[ $FLAG == "nonprod" ]] || [[ $FLAG == "stage" ]] || [[ $FLAG == "test" ]] || [[ $FLAG == "dev" ]] ; then
				FLAG="d"
				Host_Project="net-vpc-nonprod-318a"
				Host_Network="vpc-core-nonprod"
			else
				if [[ $FLAG == "shared" ]]  ; then
					FLAG="s"
					Host_Project="net-vpc-shared-65bd"
					Host_Network="vpc-core-shared"
				else
					if [[ $FLAG == "custom" ]] || [[ $FLAG == "sand" ]] || [[ $FLAG == "sandbox" ]] ; then 	
						# Not Correct but dont have options, Since sand/sandbox/Custom project not found , So didnt attached to any Host Project will use it has Standalone project
						Host_Project=$Project
						PFLAG="sa"
					fi
				fi
			fi
		fi
		
		CoreFlag="N/A"
		SPFLAG="N/A"
		SSFLAG="N/A"

	}

	GCPStart () {								# Check if Compute API is enable

		GCPComputeService=$(gcloud services list --format="value(NAME)" --project=$Project --filter="NAME:compute.googleapis.com")
		
	}

	CreateCSV () {								# Create CSV file for respective project

		echo "Creating... Output file"	
		OUTPUTCSVTEMP=$TEMPDIR/$Project"_temp.csv"
		OUTPUTCSV=$FINALOUTPUT/$Project".csv"
		echo "$OUTPUTCSV" >> $TEMPDIR/"Index"									# TEMP-Full PATH
		#Index to Output Dir with only Projectname.csv 
		echo $Project".csv" >> $MISCDIR/"Project_Index_"$LDate".txt"			# OUTPUT-Only CSV
		> $OUTPUTCSV
		> $OUTPUTCSVTEMP

	}

	AncestorsInfo () {							# Collects all Ancestore information / Not Used
		
		echo "Fetching... Ancestors Information"
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
		
		gcloud projects get-ancestors $Project  --format="csv[no-heading](id,type)" > $TEMPDIR/$Project"_AncestorInfo"
		
		sed -i "s/$Proca,folder/CA,PROD,$Project/g" $TEMPDIR/$Project"_AncestorInfo"
		sed -i "s/$Proeu,folder/EU,PROD,$Project/g" $TEMPDIR/$Project"_AncestorInfo"
		sed -i "s/$Progl,folder/GL,PROD,$Project/g" $TEMPDIR/$Project"_AncestorInfo"
		sed -i "s/$Prous,folder/US,PROD,$Project/g" $TEMPDIR/$Project"_AncestorInfo"
		
		sed -i "s/$Devca,folder/CA,NONPROD,$Project/g" $TEMPDIR/$Project"_AncestorInfo"
		sed -i "s/$Deveu,folder/EU,NONPROD,$Project/g" $TEMPDIR/$Project"_AncestorInfo"
		sed -i "s/$Devgl,folder/GL,NONPROD,$Project/g" $TEMPDIR/$Project"_AncestorInfo"
		sed -i "s/$Devus,folder/US,NONPROD,$Project/g" $TEMPDIR/$Project"_AncestorInfo"
		
		sed -i "s/$Shaca,folder/CA,SHARED,$Project/g" $TEMPDIR/$Project"_AncestorInfo"
		sed -i "s/$Shaeu,folder/EU,SHARED,$Project/g" $TEMPDIR/$Project"_AncestorInfo"
		sed -i "s/$Shagl,folder/GL,SHARED,$Project/g" $TEMPDIR/$Project"_AncestorInfo"
		sed -i "s/$Shaus,folder/US,SHARED,$Project/g" $TEMPDIR/$Project"_AncestorInfo"
		
		grep CA $TEMPDIR/$Project"_AncestorInfo" >> $TEMPDIR/$Project"_AncestorTemp"
		grep EU $TEMPDIR/$Project"_AncestorInfo" >> $TEMPDIR/$Project"_AncestorTemp"
		grep GL $TEMPDIR/$Project"_AncestorInfo" >> $TEMPDIR/$Project"_AncestorTemp"
		grep US $TEMPDIR/$Project"_AncestorInfo" >> $TEMPDIR/$Project"_AncestorTemp"
		
		Location=$(cat $TEMPDIR/$Project"_AncestorTemp" | awk -F '{print $1}')
		Folder=$(cat $TEMPDIR/$Project"_AncestorTemp" | awk -F '{print $2}')

		
	}

	ProjectInfo () {							# Collects all informamtion related to Project

		echo "Fetching... Project Information"
		gcloud app  instances list --project=$Project > $TEMPDIR/$Project"_AppInfo"
		if [[ $(cat $TEMPDIR/$Project"_AppInfo" | head -1 )  == "" ]]; then
			GCEInfo="N"
		else
			GCEInfo="Y"
		fi
		PDate=$(date)
		> $TEMPDIR/$Project"_Temp_Info"
		
		echo "Script ran on, project number,cost center,financial business unit,product team,dataclass,sls,lifecycleState,msp,Folder_Location,Folder_Type" >> $OUTPUTCSV
		PABC=$(gcloud projects describe $Project --format="csv[no-heading](projectNumber,labels.cost-center,labels.finance-business-unit,labels.product-team,labels.dataclass,labels.sls,lifecycleState,labels.msp)")    
		PN=$(echo $PABC | awk -F, '{print $1}')
		PNREST=$(echo $PABC | awk -F, '{print $2","$3","$4","$5","$6","$7","$8}')
		echo $PDate",'"$PN"',"$PNREST","$Location","$Folder >> $OUTPUTCSV
		Space
		
	}
	
	AppInfo () {								# Check & Display App Enginee Information

		if [[ $GCEInfo  = "Y" ]]; then
			echo "Fetching... App Information"
			echo "Task_Description:,App Information of Project " >> $OUTPUTCSV
			echo "GCP_Project_Name:,$Project" >> $OUTPUTCSV
			gcloud app  instances list --project=$Project --format="csv(service,instance.vmStatus,instance.id,instance.availability,instance.memoryUsage,instance.requests,instance.startTime)" >> $OUTPUTCSV
			Space
		fi
		
	}

	InstanceCheck () {							# Check if any instance is used in the project

	gcloud compute instances list --project=$Project --format="csv[no-heading](NAME)"  > $TEMPDIR/$Project"_OnlyHost"
		if [[ $(cat $TEMPDIR/$Project"_OnlyHost" | head -1) != "" ]] ; then
			IFLAG="Y"
		else
			IFLAG="N"
			echo "$Project,N/A" >> $OUTPUTCSVHOST
		fi

	}

	InstanceInfo () {							# Collects basic information on Instances & also use Instance Name as Index for rest of modules

		#5 Column
		echo "Fetching... Instance Information"
		echo "Task_Description:,Basic Instance Information" >> $OUTPUTCSV
		echo "GCP_Project_Name:,$Project,#,#,#,#,#" >> $OUTPUTCSV
		echo "name,status,zone,machine_type,internal_ip,external_ip,creationtime,bap_number(if any)" >> $OUTPUTCSV
		gcloud compute instances list --project=$Project --format="csv[no-heading](NAME,STATUS,ZONE,MACHINE_TYPE,INTERNAL_IP,EXTERNAL_IP,creationTimestamp,labels.bap-number)" > $TEMPDIR/$Project"_Host"
		cat $TEMPDIR/$Project"_Host" >> $OUTPUTCSV
		for i in $(cat $TEMPDIR/$Project"_Host" | awk -F, '{print $1","$2","$3","$(NF-3)","$(NF-2)","$NF}');
		do
			echo "$Project,$i" >> $OUTPUTCSVHOST
		done
		#cat $TEMPDIR/$Project"_Host" >> $OUTPUTCSVHOST
		#gcloud compute instances list --project=$Project --format="csv(NAME,STATUS,ZONE,MACHINE_TYPE,INTERNAL_IP,EXTERNAL_IP,creationTimestamp)" >> $OUTPUTCSV
		#gcloud compute instances list --project=$Project --format="csv(NAME,STATUS,ZONE,MACHINE_TYPE,INTERNAL_IP,EXTERNAL_IP,creationTimestamp)" >> $OUTPUTCSVHOST
		#gcloud compute instances list --project=$Project --format="csv[no-heading](NAME)"  > $TEMPDIR/$Project"_OnlyHost"
		Space
		
	}

	InstanceInfo2 () {							# Collects basic information on Instances & also use Instance Name as Index for rest of modules

		#5 Column
		echo "Fetching... Instance Information"
		echo "Task_Description:,Basic Instance Information" >> $OUTPUTCSV
		echo "GCP_Project_Name:,$Project,#,#,#,#,#" >> $OUTPUTCSV
		echo "name,status,zone,machine_type,internal_ip,external_ip,creationtime" >> $OUTPUTCSV
		gcloud compute instances list --project=$Project --format="csv[no-heading](NAME,STATUS,ZONE,MACHINE_TYPE,INTERNAL_IP,EXTERNAL_IP,creationTimestamp)" > $TEMPDIR/$Project"_Host"
		cat $TEMPDIR/$Project"_Host" >> $OUTPUTCSV
		#for i in $(cat $TEMPDIR/$Project"_Host" );
		#do
		#	echo "$Project,$i" >> $OUTPUTCSVHOST
		#done
		cat $TEMPDIR/$Project"_Host" >> $OUTPUTCSVHOST
		#gcloud compute instances list --project=$Project --format="csv(NAME,STATUS,ZONE,MACHINE_TYPE,INTERNAL_IP,EXTERNAL_IP,creationTimestamp)" >> $OUTPUTCSV
		#gcloud compute instances list --project=$Project --format="csv(NAME,STATUS,ZONE,MACHINE_TYPE,INTERNAL_IP,EXTERNAL_IP,creationTimestamp)" >> $OUTPUTCSVHOST
		#gcloud compute instances list --project=$Project --format="csv[no-heading](NAME)"  > $TEMPDIR/$Project"_OnlyHost"
		Space
		
	}

	DiskInfo () {								# Collects all the information related to disk used by Instances

		#7 Column
		echo "Fetching... Disk Information"
		echo "Task_Description:,Basic Disk Information" >> $OUTPUTCSV
		echo "GCP_Project_Name:,$Project,#,#,#,#,#,#" >> $OUTPUTCSV
		> $TEMPDIR/$Project"_DiskInfo"
		for i in {0..10}
		do
			gcloud compute instances list --project=$Project --format="csv(name,disks[$i].index,disks[$i].deviceName,disks[$i].diskSizeGb,disks[$i].boot,disks[$i].mode,disks[$i].kind,disks[$i].type)" >> $TEMPDIR/$Project"_DiskInfo"
		done
		echo "name,index,disk_name,size_gb,boot_disk,mode,kind,type" >> $OUTPUTCSV
		for i in $(cat $TEMPDIR/$Project"_OnlyHost");
		do
			cat $TEMPDIR/$Project"_DiskInfo" | grep $i | grep -v ",,,," >> $OUTPUTCSV
		done
		Space

	}

	SnapShotInfo () {							# Collects Snapshot Policy & Instances snapshots information		
					
		echo "Fetching... Snapshot Information"
		echo "Task_Description:,Snapshot Policy Information" >> $OUTPUTCSV
		echo "GCP_Project_Name:,$Project,#,#,#,#,#,#,#,#" >> $OUTPUTCSV
		> $TEMPDIR/$Project"_SnapShotInfo"
		> $TEMPDIR/$Project"_SnapShotInfo2"
		> $TEMPDIR/$Project"_SnapShotInfo3"
		
		echo "name,status,kind,start_time,duration,days_in_cycle,max_retention_days,on_source_disk_delete,guest_flush,storage_locations,region" >> $OUTPUTCSV
		gcloud compute resource-policies list --project=$Project --format="csv[no-heading](name,status,kind,snapshotSchedulePolicy.schedule.dailySchedule.startTime,snapshotSchedulePolicy.schedule.dailySchedule.duration,snapshotSchedulePolicy.schedule.dailySchedule.daysInCycle,snapshotSchedulePolicy.retentionPolicy.maxRetentionDays,snapshotSchedulePolicy.retentionPolicy.onSourceDiskDelete,snapshotSchedulePolicy.snapshotProperties.guestFlush,snapshotSchedulePolicy.snapshotProperties.storageLocations[0],region)" | awk -F"/" '{print $1","$NF}' | awk -F",https:," '{print $1","$NF}' >> $TEMPDIR/$Project"_SnapShotInfo3"
		if [[ $(cat $TEMPDIR/$Project"_SnapShotInfo3" | head -1) != "" ]]; then
			cat $TEMPDIR/$Project"_SnapShotInfo3" >> $OUTPUTCSV
			SPFLAG="Y"
		else
			echo "No Snapshot policy found:, N/A" >> $OUTPUTCSV
			SPFLAG="N"
		fi
		 
		Space
		echo "Task_Description:,Disk Snapshot Information" >> $OUTPUTCSV
		echo "GCP_Project_Name:,$Project,#,#,#,#,#" >> $OUTPUTCSV
		echo "Snapshot_name,zone,size,creatione_time,status,autocreated,kind" >> $OUTPUTCSV
		gcloud compute snapshots list  --project=$Project --format="csv[no-heading](SRC_DISK,diskSizeGb,status,autoCreated,creationTimestamp,name,kind)" | awk -F/ '{print $1","$NF}' | awk -F, '{print $2","$1","$3","$6","$4","$5","$NF}'  >> $TEMPDIR/$Project"_SnapShotInfo"
		cat $TEMPDIR/$Project"_SnapShotInfo" | grep -i True >> $TEMPDIR/$Project"_SnapShotInfo2"
		cat $TEMPDIR/$Project"_SnapShotInfo" | grep -v True >> $TEMPDIR/$Project"_SnapShotInfo2"
		if [[ $(cat $TEMPDIR/$Project"_SnapShotInfo2" | head -1) != "" ]]; then
			cat $TEMPDIR/$Project"_SnapShotInfo2" >> $OUTPUTCSV
			SSFLAG="Y"
		else
			echo "No Snapshot Found:, N/A" >> $OUTPUTCSV
			SSFLAG="N"
		fi
		Space
			
	}

	LicenseInfo () {							# Collects information on Instance licenses

		#3 Column
		echo "Fetching... License Information"
		echo "Task_Description:,SW Licensing validated" >> $OUTPUTCSV
		echo "GCP_Project_Name:,$Project,#" >> $OUTPUTCSV
		gcloud compute instances list --project=$Project --format="csv[no-heading](name, disks.licenses)" > $TEMPDIR/$Project"_LicenseInfo" 
		> $TEMPDIR/$Project"_LicenseInfo2"
		for i in $(cat $TEMPDIR/$Project"_OnlyHost");
			do
				grep $i"," $TEMPDIR/$Project"_LicenseInfo" >> $TEMPDIR/$Project"_LicenseInfo2"
			done
		echo "name,license,image" >> $OUTPUTCSV
		cat $TEMPDIR/$Project"_LicenseInfo2" | grep licenses | awk -F, '{print $1 " / " $2}'  | awk -F/ '{print $1 "," $(NF-1) "," $NF}' | awk -F"'" '{print $1 }' >> $OUTPUTCSV
		cat $TEMPDIR/$Project"_LicenseInfo2" | grep -v licenses >> $OUTPUTCSV
		Space
		
	}

	TagInfo () {								# Collects information on TAG assigned to Instances

		#12 Column
		echo "Fetching... Tag Information"
		echo "Task_Description:,Validate Prod Firewall rules are in place" >> $OUTPUTCSV
		echo "GCP_Project_Name:,$Project,#,#,#,#,#,#,#,#,#,#" >> $OUTPUTCSV

		echo "name,status,tags1,tags2,tags3,tags4,tags5,tags6,tags7,tags8,tags9,tags10" >> $OUTPUTCSV
		gcloud compute instances list --project=$Project --format="csv[no-heading](name,status,tags.items[0],tags.items[1],tags.items[2],tags.items[3],tags.items[4],tags.items[5],tags.items[6],tags.items[7],tags.items[8],tags.items[9],tags.items[10])" >> $OUTPUTCSV
		gcloud compute instances list --format='csv[no-heading](name,status,tags.list())' --project=$Project > $TEMPDIR/$Project"_TagInfo1"
		Space
		
		> $TEMPDIR/$Project"_TagInfo2"
		for i in $(cat $TEMPDIR/$Project"_TagInfo1");
		do
			echo $i >> $TEMPDIR/$Project"_TagInfo2"
		done
		cat $TEMPDIR/$Project"_TagInfo2" | grep - | awk -F"'" '{print $2}' | sort | uniq | grep . > $TEMPDIR/$Project"_TagInfo3"
		Tag_Port
		
	}

	Tag_Port () {								# Collects information on port used by that particular TAG from above module	on host project	
															
		#8 Column
		echo "Fetching... Tags / Port Information"
		echo "Task_Description:,Validate Prod Firewall rules TAG information" >> $OUTPUTCSV
		
		> $TEMPDIR/$Project"_TagInfo4"

		
		if [[ $PFLAG == "sa" ]]; then
			echo "GCP_Project_Name:,$Project,Dedicated Project,#,#,#,#,#,#" >> $OUTPUTCSV
			gcloud compute firewall-rules list --project=$Project --format="csv(targetTags.list(),name,network,direction,priority,sourceRanges.list(),disabled,allowed[].map().firewall_rule().list(),description)" >> $OUTPUTCSV
		else
			echo "GCP_Project_Name:,$Project,Host Project:,$Host_Project,#,#,#,#,#" >> $OUTPUTCSV
			echo "target_tags,name,network,direction,priority,src_ranges,disabled,allow,desciption" >> $OUTPUTCSV
			k=""
			for TAG in $(cat $TEMPDIR/$Project"_TagInfo3");
			do
				k=$(gcloud compute firewall-rules list --format="csv[no-heading]( \
				targetTags.list(),name,network,direction,priority, \
				sourceRanges.list(), \
				disabled, \
				allowed[].map().firewall_rule().list(),description \
				)" --filter="TARGET_TAGS=$TAG AND network:$Host_Network" --project=$Host_Project)
			
				if [[ $k == "" ]] ;then
					if [[ $PFLAG == "sa" ]]; then
						echo "$TAG, Not_found in Host_Project, Check Service Project" >> $TEMPDIR/$Project"_TagInfo4"
					else
						echo "$TAG, Not_found in Host_Project:, $Host_Project" >> $TEMPDIR/$Project"_TagInfo4"
					fi
				else
					echo $k >> $TEMPDIR/$Project"_TagInfo4"
				fi
			done
			grep vpc-core $TEMPDIR/$Project"_TagInfo4" >> $OUTPUTCSV
			grep -i Not_found $TEMPDIR/$Project"_TagInfo4" >> $OUTPUTCSV
		fi
		Space
		
	}

	NetworkInfo () {							# Collects information on number of NIC Instance has and connected to which subnet

		#6 Column
		echo "Fetching... Network Information"
		echo "Task_Description:,Validate Prod VLAN and IP Ranges are  configured" >> $OUTPUTCSV
		echo "GCP_Project_Name:,$Project,#,#,#,#" >> $OUTPUTCSV
		> $TEMPDIR/$Project"_NetworkNic"
	 
		gcloud compute instances list --project=$Project --format='csv(name,networkInterfaces[0].name,networkInterfaces[0].networkIP,networkInterfaces[0].subnetwork)'  | awk -F"https:" '{print $1 $2}' | awk -F/ '{print $1 $7","$9","$NF}' >> $TEMPDIR/$Project"_NetworkNic"
		gcloud compute instances list --project=$Project --format='csv(name,networkInterfaces[1].name,networkInterfaces[1].networkIP,networkInterfaces[1].subnetwork)'  | awk -F"https:" '{print $1 $2}' | awk -F/ '{print $1 $7","$9","$NF}' >> $TEMPDIR/$Project"_NetworkNic"
		gcloud compute instances list --project=$Project --format='csv(name,networkInterfaces[2].name,networkInterfaces[2].networkIP,networkInterfaces[2].subnetwork)'  | awk -F"https:" '{print $1 $2}' | awk -F/ '{print $1 $7","$9","$NF}' >> $TEMPDIR/$Project"_NetworkNic"
		gcloud compute instances list --project=$Project --format='csv(name,networkInterfaces[3].name,networkInterfaces[3].networkIP,networkInterfaces[3].subnetwork)'  | awk -F"https:" '{print $1 $2}' | awk -F/ '{print $1 $7","$9","$NF}' >> $TEMPDIR/$Project"_NetworkNic"
		gcloud compute instances list --project=$Project --format='csv(name,networkInterfaces[4].name,networkInterfaces[4].networkIP,networkInterfaces[4].subnetwork)'  | awk -F"https:" '{print $1 $2}' | awk -F/ '{print $1 $7","$9","$NF}' >> $TEMPDIR/$Project"_NetworkNic"

		> $TEMPDIR/$Project"_NetworkNic2"
		for i in $(cat $TEMPDIR/$Project"_OnlyHost");
		do
			grep $i $TEMPDIR/$Project"_NetworkNic" >> $TEMPDIR/$Project"_NetworkNic2"
		done
		echo "name,nic,ip,project,region,subnet" >> $OUTPUTCSV
		cat $TEMPDIR/$Project"_NetworkNic2" | grep nic >> $OUTPUTCSV
		Space
		
	}

	SSLInfo () {								# Collect SSL information form that particular project

		#5 Column
		echo "Fetching... SSL Information"
		echo "Task_Description:,All SSL certificate from Host Project" >> $OUTPUTCSV
		echo "GCP_Project_Name:,$Project,#,#,#" >> $OUTPUTCSV
		echo "name,type,creation_timestamp,expire_time,managed_status" >> $OUTPUTCSV
		gcloud compute ssl-certificates list --project=$Project --format="csv[no-heading](NAME,TYPE,CREATION_TIMESTAMP,EXPIRE_TIME,MANAGED_STATUS)" >> $TEMPDIR/$Project"_SSLInfo"
			if [[ $(cat $TEMPDIR/$Project"_SSLInfo" | head -1 ) != "" ]]; then
			cat $TEMPDIR/$Project"_SSLInfo" >> $OUTPUTCSV
		else
			echo "No SSL Information Found:, N/A" >> $OUTPUTCSV
		fi
		Space
	}

	LoadBalancerInfo () {						# Collect information on internal load balancer 

		#5 Column
		echo "Fetching... LoadBalancer Information"
		echo "Task_Description:,Internal LoadBalancer " >> $OUTPUTCSV
		echo "GCP_Project_Name:,$Project,#,#,#" >> $OUTPUTCSV
		echo "name,region,ip_address,ip_protocol,target" >> $OUTPUTCSV
		> $TEMPDIR/$Project"_LBInfo"
		gcloud compute forwarding-rules list --project=$Project --format="csv[no-heading](NAME,REGION,IP_ADDRESS,IP_PROTOCOL,TARGET)" >> $TEMPDIR/$Project"_LBInfo"
		if [[ $(cat $TEMPDIR/$Project"_LBInfo" | head -1 ) != "" ]]; then

			cat $TEMPDIR/$Project"_LBInfo" >> $OUTPUTCSV
		else
			echo "No LoadBalancer Found:, N/A" >> $OUTPUTCSV
		fi
		Space
		
	}

	CoreImageInfo () {							# Collect information on either standard images are used or not

		#4 Column
		echo "Fetching... Core Image Information"
		echo "Task_Description:,Verify MCK Core images in IaaS VMs" >> $OUTPUTCSV
		echo "GCP_Project_Name:,$Project,#,#" >> $OUTPUTCSV
		> $TEMPDIR/$Project"_CoreImage"
		gcloud compute disks list --project=$Project --format="csv[no-heading](name,sourceImage)" | grep https  >> $TEMPDIR/$Project"_CoreImage"
		> $TEMPDIR/$Project"_CoreImage2"
		k=""
		for i in $(cat $TEMPDIR/$Project"_OnlyHost");
		do
			k=$(cat $TEMPDIR/$Project"_CoreImage" | grep https | grep -i $i ) 
			if [[ $k == "" ]] ;then
				echo "$i , Not_found" >> $TEMPDIR/$Project"_CoreImage2"
			else
				echo $k >> $TEMPDIR/$Project"_CoreImage2"
			fi
		done
		echo "name,status,image_project,image" >> $OUTPUTCSV
		NonStdLen0=0
		NFLen=0
		CoreLen=$(cat $TEMPDIR/$Project"_CoreImage2" | wc -l)
		StdLenNa=$(cat $TEMPDIR/$Project"_CoreImage2" | grep https | grep core-imagesna | wc -l)
		StdLenEu=$(cat $TEMPDIR/$Project"_CoreImage2" | grep https | grep core-imageseu | wc -l)
		NonStdLen1=$(cat $TEMPDIR/$Project"_CoreImage2" | grep https | grep -v core-images | wc -l)
		NFLen=$(cat $TEMPDIR/$Project"_CoreImage2" | grep Not_found | wc -l)
		
		cat $TEMPDIR/$Project"_CoreImage2" | grep https |  awk -F, '{print $1 " / " $NF}' | awk -F/ '{print $1 ",STANDARD_IMAGE," $(NF-3) "," $NF }' | grep core-imagesna  >> $OUTPUTCSV
		cat $TEMPDIR/$Project"_CoreImage2" | grep https |  awk -F, '{print $1 " / " $NF}' | awk -F/ '{print $1 ",STANDARD_IMAGE," $(NF-3) "," $NF }' | grep core-imageseu  >> $OUTPUTCSV
		
		if [[ $FLAG == "p" ]]; then
			cat $TEMPDIR/$Project"_CoreImage2" | grep https |  awk -F, '{print $1 " / " $NF}' | awk -F/ '{print $1 ",NONSTANDARD_IMAGE," $(NF-3) "," $NF }' | grep core-images-  >> $OUTPUTCSV
			NonStdLen0=$(cat $TEMPDIR/$Project"_CoreImage2" | grep https | grep core-images- | wc -l)
			StdLen=`expr $StdLenNa + $StdLenEu + $NonStdLen0`
			NonStdLen=$NonStdLen1
		else
			cat $TEMPDIR/$Project"_CoreImage2" | grep https |  awk -F, '{print $1 " / " $NF}' | awk -F/ '{print $1 ",STANDARD_IMAGE," $(NF-3) "," $NF }' | grep core-images-  >> $OUTPUTCSV
			NonStdLen0=$(cat $TEMPDIR/$Project"_CoreImage2" | grep https | grep core-images- | wc -l)
			StdLen=`expr $StdLenNa + $StdLenEu`
			NonStdLen=`expr $NonStdLen0 + $NonStdLen1`
		fi
		
		cat $TEMPDIR/$Project"_CoreImage2" | grep https |  awk -F, '{print $1 " / " $NF}' | awk -F/ '{print $1 ",NONSTANDARD_IMAGE," $(NF-3) "," $NF }' | grep -v core-images  >> $OUTPUTCSV
		cat $TEMPDIR/$Project"_CoreImage2" | grep Not_found | awk '{print $1",N/A"}' >> $OUTPUTCSV
		
		SumLen=`expr $StdLen + $NonStdLen + $NFLen`

		if [[ $CoreLen == $StdLen ]]; then
			CoreFlag="Y"
		else
			if [[ $CoreLen == $NonStdLen ]]; then
				CoreFlag="N"
			else
				if [[ $CoreLen == $SumLen ]]; then
					CoreFlag="Both"
				else
					if [[ $CoreLen == $NFLen ]]; then
						CoreFlag="N/A"
					else
						echo "Check manually"
					fi
				fi
			fi	
		fi
		#echo "Core Images Used? :, $CoreFlag" >> $OUTPUTCSV
		Space
		
	}

	FileTransfer() {							# Swap the main output file Important module

		echo "Application Name,Project Name,Project ID,BAP,Environment,Project Owner,Technical owner,Project Creation Date,GCE Used?,GAE Used?,Core Images Used?,Snapshot Policy Exists?,Snapshots Exists?" >> $OUTPUTCSVTEMP
		CABC=$(gcloud projects describe $Project --format="csv[no-heading](name,projectId,labels.bap-number,labels.env,labels.project-owner,labels.tech-owner)") 
		CBC=$(gcloud projects describe $Project --format="csv[no-heading](createTime)" | awk -FT '{print $1}' ) 
		echo "XXX,$CABC,$CBC,$IFLAG,$GCEInfo,$CoreFlag,$SPFLAG,$SSFLAG" >> $OUTPUTCSVTEMP
		echo "" >> $OUTPUTCSVTEMP
		cat $OUTPUTCSV >> $OUTPUTCSVTEMP
		cat $OUTPUTCSVTEMP > $OUTPUTCSV
		rm $OUTPUTCSVTEMP
		echo "XXX,$CABC,$CBC,$IFLAG,$GCEInfo,$CoreFlag,$SPFLAG,$SSFLAG" >> $OUTPUTCSV2
		
	}

	IamInfo () {								# Collects information of service account attached to that project

		#3 Column
		echo "Fetching... IAM Information"
		echo "Task_Description:,IAM Information of Project " >> $OUTPUTCSV
		echo "GCP_Project_Name:,$Project,#" >> $OUTPUTCSV
		gcloud iam service-accounts list --project=$Project --format="csv(displayName,email,disabled)"   >> $OUTPUTCSV
		Space
		
	}

	GCPService () {								# Collects information on which API service is enable

		#3 Column
		echo "Fetching... GCP Enabled Service Information"
		echo "Task_Description:,GCP enabled service in this project " >> $OUTPUTCSV
		echo "GCP_Project_Name:,$Project,#" >> $OUTPUTCSV
		gcloud services list --project=$Project --format="csv(NAME,TITLE)" | awk -F, '{print $1","$2}' >> $OUTPUTCSV
		Space
		
	}

	Credit () {									# Credit / Version 

	Space
	Space
	echo "####,####,####,####,####"  >> $OUTPUTCSV
	echo "Script created by :,Prasanchandra Lakhani"  >> $OUTPUTCSV
	echo "Email:, prasanchandra.lakhani@atos.net"  >> $OUTPUTCSV
	echo "Script Version:, $Version" >> $OUTPUTCSV
	echo "####,####,####,####,####"  >> $OUTPUTCSV

}

	CloudStorage () {							# Collects Cloud Storage Information / gets heavy when lot of data

		#2 Column
		echo "Fetching... Cloud Storage Information"
		echo "Task_Description:,Storage information with Size " >> $OUTPUTCSV
		echo "GCP_Project_Name:,$Project" >> $OUTPUTCSV
		echo "storage_bucket,size,B/KB/MB/GB/TB" >> $OUTPUTCSV
		gsutil -o GSUtil:default_project_id=$Project du -shc | awk '{print $NF","$1","$2}' >> $OUTPUTCSV
		Space

	}

	CloudSQL () {								# Collects Cloud SQl information

		#13 Column
		echo "Fetching... Cloud SQL Information"
		echo "Task_Description:, CloudSQL Information " >> $OUTPUTCSV
		echo "GCP_Project_Name:,$Project,#,#,#,#,#,#" >> $OUTPUTCSV
		echo "name,database_version,location,tier,primary_address,private_address,status,disksizegb" >> $OUTPUTCSV
		gcloud sql instances list --project=$Project --format="csv[no-heading](NAME,DATABASE_VERSION,LOCATION,TIER,PRIMARY_ADDRESS,PRIVATE_ADDRESS,STATUS,settings.dataDiskSizeGb)"  >> $TEMPDIR/$Project"_CloudSQL"
		
		if [[ $(cat $TEMPDIR/$Project"_CloudSQL" | head -1) != "" ]]; then
			cat $TEMPDIR/$Project"_CloudSQL" >> $OUTPUTCSV
			Space
			#echo "Task_Description:,More information on SQL cluster with Size , backup & Autoresize " >> $OUTPUTCSV
			#echo "GCP_Project_Name:,$Project,#,#,#,#,#" >> $OUTPUTCSV
			echo "name,backup_enabled,start_time,data_disk_type,storage_auto_resize,storage_auto_resize_limit,private_network" >> $OUTPUTCSV
			gcloud sql instances list --project=$Project --format="csv[no-heading](NAME,settings.backupConfiguration.enabled,settings.backupConfiguration.startTime,settings.dataDiskType,settings.storageAutoResize,settings.storageAutoResizeLimit,settings.ipConfiguration.privateNetwork)" | awk -F"projects/" '{print $1"/"$2}' | awk -F/ '{print $1$(NF-2)"_"$(NF-1)"_"$NF}' >> $OUTPUTCSV
		else
			echo "No CloudSQL Information found:, N/A" >> $OUTPUTCSV
		fi
		
		
		
		
		#lod-prod-mysql,MYSQL_5_7,europe-west2-a,db-n1-standard-1,-,10.251.25.3,RUNNABLE,False,16:00,PD_SSD,True,0,global_networks_core-vpc
		Space

	}

	Logging () {								# No Permission undeveloped module

		echo "Pending"
		
	}

	PubSub () {									# Undeveloped module

		echo "Pending"
		
	}

	CloudFuntion () {							# Undeveloped module

		echo "Pending"
		
	}

	Output () {									# Displace output module
		
		#clear
		#cat $OUTPUTCSV 						#Enable for troubleshooting / Works with -p or -plite only
		Star
		Star
		echo "Output File Location : "
		if [[ $SINGLE == "Y" ]]; then
			cat $TEMPDIR/"Index"
			echo "click top right 3 dot button , Select Download File & copy/paste above location to download file to local Desktop"
		else
			if [[ $SINGLE == "N" ]]; then
				
				echo "Download Zip File : "$ZIPIT 
				echo "click top right 3 dot button , Select Download File & copy/paste above location to download file to local Desktop"
				Hash
				echo "Collective Header output : $OUTPUTCSV2"
				Hash
				echo "Collective Host Output   : $OUTPUTCSVHOST"
			fi
		fi
		#cat $OUTPUTCSV2						#Enable for troubleshooting
		

		Hash
		echo "LOG File : $LOGTXT"
		#Star
		
	}

	OutputCloud () {							# Save data to Cloud Bucket

	echo "Pending"

	#WORKINGDIR=$(pwd)
	#OUTPUTDIR=$WORKINGDIR/Output
	#TEMPDIR=$OUTPUTDIR/Temp
	#LOGDIR=$OUTPUTDIR/LOG
	#MISCDIR=$OUTPUTDIR/Misc
	#FINALOUTPUT=$OUTPUTDIR/FinalOutput

	#Bucket="prasantest"


	#FULL Dir No needed
	#gsutil cp $OUTPUTDIR/*.txt gs://$Bucket

	#IMP : FINAL OUTPUT
	#gsutil cp $FINALOUTPUT/*.csv gs://$Bucket

	#LOG
	#gsutil cp $TEMPDIR/*.LOG gs://$Bucket


	}

	ZipContinuos () {							# Zip the file into single downladed file
		echo "Zipping.... It "
		
		cd $FINALOUTPUT
		#echo $ZIPIT
		#ZipName="Zip_$Ldate.zip"
		zip -r $ZIPIT $Project".csv" > $TEMPDIR/"ZipIt"
		#zip $ZIPIT -@ < $MISCDIR/"Project_Index_"$LDate".txt"
		cd $MISCDIR
		zip -r $ZIPIT "Project_Info_"$LDate".csv" > $TEMPDIR/"ZipIt"
		zip -r $ZIPIT "Host_Info_"$LDate".csv" > $TEMPDIR/"ZipIt"
		cd $LOGDIR
		zip -r $ZIPIT "LOG_"$LDate".log" > $TEMPDIR/"ZipIt"
		cd $WORKINGDIR

	}

	Ziplast () {								# Zip Pending
	
		echo "Zipping.... It "
		cd $FINALOUTPUT
		echo $ZIPIT
		#ZipName="Zip_$Ldate.zip"
		zip $ZIPIT -@ < $MISCDIR/"Project_Index_"$LDate".txt"
		cd $MISCDIR
		zip -r $ZIPIT "Project_Info_"$LDate".csv"
		zip -r $ZIPIT "Host_Info_"$LDate".csv"
		cd $LOGDIR
		zip -r $ZIPIT "LOG_"$LDate".log"
		cd $WORKINGDIR

	}

	Stack () {									# Main Module

		SetProject "$1" "$2"
		Hash
		if [[ $Project != "" ]]; then
			SetFlag
			GCPStart
			InstanceCheck
			CreateCSV
			AncestorsInfo
			ProjectInfo 		
			AppInfo		
			if [[ $GCPComputeService == "compute.googleapis.com" ]] && [[ $IFLAG == "Y" ]] ; then
				InstanceInfo 		
				##Above Function Mandatory
				#
				LicenseInfo  		
				TagInfo 			
				NetworkInfo 			
				CoreImageInfo 	
				DiskInfo			
				SnapShotInfo
				#echo ""
			else
				#echo ""
				if [[ $GCPComputeService != "compute.googleapis.com" ]]; then
					echo "API Service : $GCPComputeService not activated"
				else
					if [[ $IFLAG != "Y" ]]; then
						echo "No Compute instance found"
					fi
				fi	
			fi
			##Logging
			##PubSub
			##CloudFuntion		
			FileTransfer				#Important Module		
			SSLInfo	
			LoadBalancerInfo
			CloudStorage
			CloudSQL
			IamInfo
			GCPService
			Credit
			#echo "#"
			if [[ $SINGLE == "N" ]]; then
				ZipContinuos
			fi
		fi
		
	}

	StackLite () {								# Main Lite Module
		SetProject "$1" "$2"
		Hash
		if [[ $Project != "" ]]; then
			SetFlag
			GCPStart
			InstanceCheck
			CreateCSV
			AncestorsInfo
			ProjectInfo 		
			AppInfo		
			if [[ $GCPComputeService == "compute.googleapis.com" ]] && [[ $IFLAG == "Y" ]] ; then
				InstanceInfo 		
				##Above Function Mandatory
				#
				LicenseInfo  		
				TagInfo 			
				NetworkInfo 			
				CoreImageInfo 	
				DiskInfo			
				SnapShotInfo
				#echo ""
			else
				#echo ""
				if [[ $GCPComputeService != "compute.googleapis.com" ]]; then
					echo "API Service : $GCPComputeService not activated"
				else
					if [[ $IFLAG != "Y" ]]; then
						echo "No Compute instance found"
					fi
				fi	
			fi
			##Logging 
			##PubSub
			##CloudFuntion
			FileTransfer				#Mandatory Module		
			SSLInfo	
			LoadBalancerInfo
			#CloudStorage
			CloudSQL
			#IamInfo
			#GCPService
			#echo "#"
			Credit
			if [[ $SINGLE == "N" ]]; then
				ZipContinuos
			fi
		fi
		
	}

	Stacktemp () {								# Main temp Module for Developing only
		
		SetProject "$1" "$2"
		Hash
		if [[ $Project != "" ]]; then
			SetFlag
			GCPStart
			InstanceCheck
			CreateCSV
			AncestorsInfo
			ProjectInfo 		
			AppInfo		
			if [[ $GCPComputeService == "compute.googleapis.com" ]] && [[ $IFLAG == "Y" ]] ; then
				InstanceInfo 		
				##Above Function Mandatory
				#
				#LicenseInfo  		
				#TagInfo 			
				#NetworkInfo 			
				#CoreImageInfo 	
				#DiskInfo			
				#SnapShotInfo
				#echo ""
			else
				#echo ""
				if [[ $GCPComputeService != "compute.googleapis.com" ]]; then
					echo "API Service : $GCPComputeService not activated"
				else
					if [[ $IFLAG != "Y" ]]; then
						echo "No Compute instance found"
					fi
				fi	
			fi
			##Logging 
			##PubSub
			##CloudFuntion
			FileTransfer				#Mandatory Module		
			#SSLInfo	
			#LoadBalancerInfo
			#CloudStorage
			#CloudSQL
			#IamInfo
			#GCPService
			#echo "#"
			Credit
			if [[ $SINGLE == "N" ]]; then
				ZipContinuos
			fi
		fi
		
	}

	main () {									# Execute Stack module based on flag provided 
		
		Counter	
		#******************************************************************************
		if [[ $1 == "-p" ]] && [[ $2 != "" ]] ; then
			Star
			Stack "$2"
			SINGLE="Y"
			if [[ $Project != "" ]]; then
				Output
			fi
			Star
		fi
		#******************************************************************************
		if [[ $1 == "-plite" ]] && [[ $2 != "" ]] ; then
			Star
			StackLite "$2"
			SINGLE="Y"
			if [[ $Project != "" ]]; then
				Output
			fi
			Star
		fi
		#******************************************************************************
		if [[ $1 == "-ptemp" ]] && [[ $2 != "" ]] ; then
			Star
			Stacktemp "$2"
			SINGLE="Y"
			if [[ $Project != "" ]]; then
				Output
			fi
			Star
		fi
		#******************************************************************************		
		if [[ $1 == "-s" ]] && [[ $2 != "" ]] ; then
			Star
			Stack "$2" "$1"	
			SINGLE="Y"
			if [[ $Project != "" ]]; then
				Output
			fi
			Star
		fi
		#******************************************************************************
		if [[ $1 == "-f" ]] && [[ $2 != "" ]] ; then
			FileLen=$(cat $2 | sed -r '/^\s*$/d' | wc -l)
			if [[ $FileLen != 0 ]]; then
				SINGLE="N"
				for i in $(cat $2 | sed -r '/^\s*$/d' )
				do
					Star
					echo "Remaining Project : "$FileLen
					Star
					Stack "$i" 
					((FileLen=FileLen-1))
				done
				Output
			else
				usage
				exit 1
			fi	
		fi
		#******************************************************************************
		if [[ $1 == "-flite" ]] && [[ $2 != "" ]] ; then
			FileLen=$(cat $2 | sed -r '/^\s*$/d' | wc -l)
			if [[ $FileLen != 0 ]]; then
				SINGLE="N"
				for i in $(cat $2 | sed -r '/^\s*$/d' )
				do
					Star
					echo "Remaining Project : "$FileLen
					Star
					StackLite "$i" 
					((FileLen=FileLen-1))
				done
				Output
			else
				usage
				exit 1
			fi	
		fi
		#******************************************************************************
		if [[ $1 == "-ftemp" ]] && [[ $2 != "" ]] ; then
			FileLen=$(cat $2 | sed -r '/^\s*$/d' | wc -l)
			if [[ $FileLen != 0 ]]; then
				SINGLE="N"
				for i in $(cat $2 | sed -r '/^\s*$/d' )
				do
					Star
					echo "Remaining Project : "$FileLen
					Star
					Stacktemp "$i" 
					((FileLen=FileLen-1))
				done
				Output
			else
				usage
				exit 1
			fi	
			
		fi
		
		if [[ $1 == "" ]] || [[ $2 == "" ]] ; then 
			usage
			exit 1
		fi
		
	}

	#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	main "$1" "$2" | tee -a $LOGTXT				# Main Program & Collects Logs as log file

	rm -r $TEMPDIR								# Clean up temp directory

	#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
