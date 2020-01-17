./mvnw clean package -DskipTests

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

export GCP_REDIS_IP=$(gcloud redis instances describe demo --region=${GCP_REGION} --format="json" | jq -r '.host')

echo "Configuring Runtime"

gcloud services enable runtimeconfig.googleapis.com

gcloud beta runtime-config configs create hahelloworld_cloud

gcloud beta runtime-config configs variables set welcome.message "Hello" --config-name hahelloworld_cloud

gcloud beta runtime-config configs variables list --config-name=hahelloworld_cloud

gcloud beta runtime-config configs variables get-value welcome.message --config-name=hahelloworld_cloud

echo "Configuring Spanner"

gcloud services enable spanner.googleapis.com

gcloud spanner instances create demo --config=regional-us-central1 --nodes=1 --description="SouJava"

gcloud spanner databases create soujavadb --instance=demo

gcloud spanner databases list --instance=demo

gcloud spanner databases ddl update soujavadb --instance=demo --ddl="$(<schema.ddl)"

echo "Configuring Stackdriver"

gcloud services enable cloudtrace.googleapis.com

echo "Configuring compute instance"

gcloud compute addresses create my-lb-ip --region ${GCP_REGION}

export LB_IP_ADDRESS=$(gcloud compute addresses describe my-lb-ip --region=${GCP_REGION} --format=json | jq -r '.address')

echo "Your ip is ${LB_IP_ADDRESS}"

gcloud compute instances create instance-1 --zone ${GCP_ZONE}

export GCP_SERVICE_ACCOUNT=$(gcloud compute instances describe instance-1 --zone=us-central1-c --format="json" | jq -r '.serviceAccounts[0].email')

gcloud compute instances stop instance-1

gcloud compute instances set-service-account instance-1 --zone=us-central1-c --service-account ${GCP_SERVICE_ACCOUNT} --scopes cloud-platform

gcloud compute instances start instance-1

gcloud compute http-health-checks create myhc-http-port-8080 --description="HTTP port 8080 health check" --check-interval=5s --timeout=5s --healthy-threshold=2 --unhealthy-threshold=2 --port=8080 --request-path="/actuator/health"

gcloud compute target-pools create my-pool --region ${GCP_REGION} --http-health-check myhc-http-port-8080

gcloud compute target-pools add-instances my-pool --instances instance-1 --instances-zone=${GCP_ZONE}

gcloud compute forwarding-rules create app-rule --region ${GCP_REGION} --ports 8080 --address ${LB_IP_ADDRESS} --target-pool my-pool

gcloud compute firewall-rules create demoservice --allow tcp:8080

gcloud compute scp target/soujava-demo-2020-0.0.1-SNAPSHOT.jar instance-1:~/

gcloud compute ssh instance-1 --command "sudo apt-get -y install openjdk-8-jdk-headless"

gcloud compute ssh instance-1 --command "java -jar -Dspring.profiles.active=cloud -Dspring.redis.host=${GCP_REDIS_IP} ~/soujava-demo-2020-0.0.1-SNAPSHOT.jar &"
