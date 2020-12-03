#! /bin/bash
# A startup file for running any file in data/ using GOOGLE COMPUTE ENGINE

# User defined parameters
ID="01"                                        # experiment id
VM_NAME="blopimpute"                           # VM instance name
CPLEX_GCS_BIN="gs://cplex-1210/cplex-1210.bin" # cplex .bin location
OUTPUT_GCS_CSV="gs://blopimpute/exp-${ID}.csv" # .csv destination
# Notes:
# - The VM must be created in us-central1-a
# - The last two files must be in GCS buckets.

# Install JRE 2:1.11-72
sudo apt update
sudo apt --assume-yes install default-jre=2:1.11-72

# Install CPLEX 12.10
gsutil cp ${CPLEX_GCS_BIN} cplex.bin
chmod +x cplex.bin
CPLEX_DIR="/opt"
sudo ./cplex.bin \
    -i silent \
    -DINSTALLER_UI=silent \
    -DLICENSE_ACCEPTED=TRUE \
    -DUSER_INSTALL_DIR=${CPLEX_DIR}
export CPLEX_STUDIO_BINARIES="${CPLEX_DIR}/cplex/bin/x86-64_linux/"
rm -rf cplex.bin

# Install Julia 1.5.3
url="https://julialang-s3.julialang.org/bin/linux/x64"
url="${url}/1.5/julia-1.5.3-linux-x86_64.tar.gz"
wget ${url// /}
tar -xvzf julia-1.5.3-linux-x86_64.tar.gz
sudo cp -r julia-1.5.3 /opt/
sudo ln -s /opt/julia-1.5.3/bin/julia /usr/local/bin/julia
sudo apt --assume-yes autoremove -f
rm -rf julia-1.5.3*

# Run experiment
git clone https://github.com/igutierrezm/BLOPimpute-experiments.git
cd BLOPimpute-experiments
julia data/exp-${ID}.jl

# Save results
gsutil cp data/exp-${ID}.csv ${OUTPUT_GCS_CSV}

# Delete VM
gcloud compute instances delete ${VM_NAME} --zone us-central1-a --quiet