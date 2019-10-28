./mvnw clean package -DskipTests -Pcloud

export PROJECT_ID=
export GCP_BILLING_ACCOUNT_ID=
export GCP_REGION=us-central1
export GCP_ZONE=us-central1-c

gcloud projects create ${PROJECT_ID}

gcloud beta billing projects link ${PROJECT_ID} --billing-account=${GCP_BILLING_ACCOUNT_ID}

gcloud config set project ${PROJECT_ID}
gcloud config set compute/region ${GCP_REGION}
gcloud config set compute/zone ${GCP_ZONE}

echo "Configuring Memorystore"

gcloud services enable redis.googleapis.com

gcloud redis instances create demo --size=1 --region=${GCP_REGION}

gcloud redis instances describe demo --region=${GCP_REGION} | grep host

echo "Configuring Runtime"

gcloud services enable runtimeconfig.googleapis.com

gcloud beta runtime-config configs create hahelloworld_cloud

gcloud beta runtime-config configs variables set welcome.message "Hello" --config-name hahelloworld_cloud

gcloud beta runtime-config configs variables list --config-name=hahelloworld_cloud

gcloud beta runtime-config configs variables get-value welcome.message --config-name=hahelloworld_cloud

echo "Configuring Spanner"

gcloud services enable spanner.googleapis.com

gcloud spanner instances create demo --config=regional-us-central1 --nodes=1 --description="DevFest Lima 19"

gcloud spanner databases create devfest --instance=demo

gcloud spanner databases list --instance=demo

gcloud spanner databases ddl update devfest --instance=demo --ddl="$(<schema.ddl)"

echo "Configuring Stackdriver"

gcloud services enable cloudtrace.googleapis.com

echo "Configuring compute instance"

gcloud compute instances create instance-1 --zone ${GCP_ZONE}

export GCP_SERVICE_ACCOUNT=$(gcloud compute instances describe instance-1 --zone=us-central1-c --format="json" | jq -r '.serviceAccounts[0].email')

gcloud compute instances stop instance-1

gcloud compute instances set-service-account instance-1 --zone=us-central1-c --service-account ${GCP_SERVICE_ACCOUNT} --scopes cloud-platform

gcloud compute instances start instance-1

gcloud compute scp target/devfest-demo-2019-0.0.1-SNAPSHOT.jar instance-1:~
