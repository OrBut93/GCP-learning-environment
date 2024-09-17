
########## START HERE ###########
#################################

#open the CSV file with the users. the columms need to be : first name, last name. email
#the first row need to be first_name, last_name, email
#upload the csv file to Terminal with name users.csv

#print all columms to see that file uploaded
#cat students.csv
#################################


######################
# PARAMETERS
######################

number_of_students=2;
billing_account=013F60-C433EA-67D57E;
file_name="students.csv"
course_folder_id="462978832491"

######################
#FOLDERS
######################

# CREATE STUDENTS FOLDER

# Replace PARENT_FOLDER_ID with the actual parent folder ID of the school
FOLDER_PATH=$(gcloud alpha resource-manager folders create \
    --display-name="students" \
    --folder=$course_folder_id \
    --format="value(name)")

#get the id of the new folder
folder_id=$(echo $FOLDER_PATH | cut -d'/' -f2)
echo $folder_id


######################
#START LOOP - STUDENTS
######################

for (( i=2; i<=$number_of_students; i++ ))
do
	
	#print command is the columm 1&2, first name and last name together.! 
	echo " "
	echo " "
	echo " "
	
	#save the first and last name as one in user_name variable.
	user_name=$(awk -F',' -v row_number=$i 'NR==row_number {print $1 $2}' $file_name | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')  
	
	#save the users's mail in user_mail variable.
	user_mail=$(awk -F',' -v row_number=$i 'NR==row_number {print $3}' $file_name | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]') 
	
	#print the variables.
	echo "###NEW PROJECT FOR : $user_name"
	echo " "
	echo "###USER MAIL IS: $user_mail"
	echo " "

	echo " "
	echo "###CREATE THE PROJECT"
	echo " "
	
	######################
	#CREATE PROJECT
	######################

	 gcloud projects create $user_name \
	--folder=$folder_id \
	--name=$user_name \
	--quiet

	######################
	#CONNECT BILLING
	######################

	echo " " 
	echo "###Connect Billing"
	echo " "
	gcloud billing projects link $user_name --billing-account $billing_account

	######################
	#PERMISSIONS TO USER
	######################

	echo " "
	echo "###Add Permissions To User"
	echo " "
	gcloud config set project $user_name
	
	gcloud projects add-iam-policy-binding $user_name \
    --member=user:$user_mail \
	--role=roles/viewer \
    

	gcloud projects add-iam-policy-binding $user_name \
    --member=user:$user_mail \
	--role=roles/dataform.viewer \

	gcloud projects add-iam-policy-binding $user_name \
    --member=user:$user_mail \
	--role=roles/aiplatform.colabEnterpriseUser \
    

	######################
	#ENABLE APIS
	######################

	echo " "
	echo "###ENABLE MONITORING API"
	echo " "
	
	gcloud config set project $user_name

	gcloud services enable monitoring.googleapis.com --project=$user_name

	echo " "
	echo "###ENABLE BILLING API"
	echo " "
	gcloud services enable billingbudgets.googleapis.com --project=$user_name
	

	echo " "
	echo "###ENABLE VERTEX AI API"
	echo " "
	
	gcloud config set project $user_name
	gcloud services enable aiplatform.googleapis.com
	
	echo " "
	echo "###ENABLE COMPUTE ENGINE API"
	echo " "
	
	gcloud config set project $user_name
	gcloud services enable compute.googleapis.com


	######################
	#NOTIFICATION CHANNEL
	######################

	echo " "
	echo "###CREATE NOTIFICATION CHANNEL"
	echo " "
	
	gcloud beta monitoring channels create \
    --type=email \
	--display-name=$user_name \
    --channel-labels=email_address=$user_mail
	
	
	echo " "
	echo "###CREATE NOTIFICATION CHANNEL FOR TEACHERS"
	echo " "
	
	gcloud config set project $user_name

	#CHANGE ACCORDING TO THE ACTUAL NUMBER OF TEACHERS.

	gcloud beta monitoring channels create \
    --type=email \
	--display-name=ShayLitvak \
    --channel-labels=email_address=shai.litvak@runi.ac.il
	
	gcloud beta monitoring channels create \
    --type=email \
	--display-name=ShayLitvak \
    --channel-labels=email_address=shai.litvak@runi.ac.il
	

	
done