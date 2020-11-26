#! /bin/bash
sudo apt update

# JRE 2:1.11-72
sudo apt --assume-yes install default-jre=2:1.11-72

# CPLEX 12.10
gsutil cp gs://cplex-1210/cplex-1210.bin cplex-1210.bin
chmod +x cplex-1210.bin
CPLEX_DIR="/opt/ibm/ILOG/CPLEX_Studio_Community1210"
sudo ./cplex-1210.bin \
    -i silent \
    -DINSTALLER_UI=silent \
    -DLICENSE_ACCEPTED=TRUE \
    -DUSER_INSTALL_DIR=${CPLEX_DIR}
export CPLEX_STUDIO_BINARIES=${CPLEX_DIR}/cplex/bin/x86-64_linux/
rm -rf cplex-1210.bin

# Julia 1.5.3
url="
    https://julialang-s3.julialang.org/bin/linux/\
    x64/1.5/julia-1.5.3-linux-x86_64.tar.gz
"
wget ${url// /}
tar -xvzf julia-1.5.3-linux-x86_64.tar.gz
sudo cp -r julia-1.5.3 /opt/
sudo ln -s /opt/julia-1.5.3/bin/julia /usr/local/bin/julia
sudo apt --assume-yes autoremove -f
rm -rf julia-1.5.3*


# gcloud beta compute --project=gcp-test-296413 instances create instance-1 --zone=us-central1-a --machine-type=f1-micro --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=906931621342-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --image=ubuntu-2010-groovy-v20201111 --image-project=ubuntu-os-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=instance-1 --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
# ssh-keygen -R 34.71.128.4