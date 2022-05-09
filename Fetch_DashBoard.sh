#!/bin/bash
echo "**************************************************************************"
if [ $(echo $1) == "con" ] ; then
	PROJECT_ID="cops-osmon-nonprod-b6c0"
else
	if [ $(echo $1) == "cat" ] ; then
		PROJECT_ID="core-automation-test-fddb"
	else
		if [ $(echo $1) == "" ] ; then
			echo "Please Provide Project ID"
			exit 1
		else
			echo "Searching... Project Name"
			gcloud projects list > PROJECT_LIST
			Project_1=$(grep -i $1 PROJECT_LIST | awk '{print $1}')
			if [[ $Project_1 == "" ]] ;then
				echo "NOT FOUND... Project : $1"
				PROJECT_ID=""
				exit 1
			else
				PROJECT_ID=$(echo $Project_1 | awk '{print $1}')
			fi
		rm PROJECT_LIST
		fi
	fi
fi
echo "**************************************************************************"
echo "Authenticating"
ACCESS_TOKEN=`gcloud auth print-access-token`
echo "Fetching all dashboard"
curl -H "Authorization: Bearer $ACCESS_TOKEN" https://monitoring.googleapis.com/v1/projects/${PROJECT_ID}/dashboards > Temp.json
echo "**************************************************************************"
cat Temp.json | grep -i 'name": "'
echo "**************************************************************************"
echo "**************************************************************************"
echo "Enter dashboard ID, which you want to download from $PROJECT_ID"
read DASHBOARD_ID
echo "**************************************************************************"
echo "Fetching choosen dashboard"
echo "**************************************************************************"

curl -H "Authorization: Bearer $ACCESS_TOKEN" https://monitoring.googleapis.com/v1/projects/${PROJECT_ID}/dashboards/${DASHBOARD_ID} > Temp.json
echo "**************************************************************************"
sed -i '/"name":/d' Temp.json
sed -i '/"etag":/d' Temp.json
CHILD_PROJECT=$(cat Temp.json | grep "project_id" | head -n 1 | awk -F= '{print $NF}' | awk -F'\' '{print $2}' | awk -F'"' '{print $NF}')
if [ $(echo $CHILD_PROJECT | awk -F '-' '{print NF}') == "4" ] ; then
ABC="XXXX-XXXX-XXXX-XXXX"
sed -i "s/$CHILD_PROJECT/$ABC/g" Temp.json
fi
DISPLAYNAME=$(cat Temp.json | grep displayName | awk -F'"' '{print $(NF-1)}')
echo "PROJECT NAME : "$PROJECT_ID
echo "DASHBOARD ID : "$DASHBOARD_ID
echo "DASHBOARD NAME : "$DISPLAYNAME
cp  Temp.json  $DISPLAYNAME".json"
echo "Filename with location : "$(pwd)"/"$DISPLAYNAME".json"
