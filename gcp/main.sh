#! /bin/bash
gcloud beta compute \
    --project=gcp-test-296413 instances create blopimpute \
    --zone=us-central1-a \
    --machine-type=e2-standard-8 \
    --subnet=default \
    --network-tier=PREMIUM \
    --maintenance-policy=MIGRATE \
    --service-account=906931621342-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --image=ubuntu-2010-groovy-v20201111 \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=200GB \
    --boot-disk-type=pd-standard \
    --boot-disk-device-name=blopimpute \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any \
    --metadata-from-file startup-script=gcp/startup.sh

###
### The following code creates a RStudio server in GCE
###

# gcloud beta compute 
#     --project=gcp-test-296413 instances create rstudio 
#     --zone=europe-west6-a 
#     --machine-type=e2-standard-8 
#     --subnet=default 
#     --network-tier=PREMIUM 
#     --maintenance-policy=MIGRATE 
#     --service-account=906931621342-compute@developer.gserviceaccount.com 
#     --scopes=https://www.googleapis.com/auth/cloud-platform 
#     --tags=rstudio,http-server 
#     --image=ubuntu-2004-focal-v20201111 
#     --image-project=ubuntu-os-cloud 
#     --boot-disk-size=50GB 
#     --boot-disk-type=pd-standard 
#     --boot-disk-device-name=rstudio 
#     --no-shielded-secure-boot 
#     --shielded-vtpm 
#     --shielded-integrity-monitoring 
#     --reservation-affinity=any



# sudo apt update -y
# sudo apt upgrade -y

# # Add CRAN repo to the lists of sources
# sudo apt-key adv \
#     --keyserver keyserver.ubuntu.com \
#     --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
# sudo add-apt-repository \
#     'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'

# # Install R
# sudo apt install r-base r-base-core r-recommended r-base-dev -y

# # Install RStudio
# sudo apt-get install gdebi-core
# wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.3.1093-amd64.deb
# sudo gdebi rstudio-server-1.3.1093-amd64.deb --n

# # Install supporting packages
# sudo apt-get install libcurl4-openssl-dev libssl-dev libxml2-dev

# # Add user (master) and password (123)
# useradd -p $(openssl passwd -crypt 123) master
