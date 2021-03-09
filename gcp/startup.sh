#! /bin/bash
# Run data/exp-${ID}.jl and save the produced csv file in gs://blopimpute
ID="04"

# Install JRE 2:1.11-72
sudo apt update
sudo apt --assume-yes install default-jre=2:1.11-72

# Install CPLEX 12.10
gsutil cp gs://cplex-1210/cplex-1210.bin cplex.bin
chmod +x cplex.bin
sudo ./cplex.bin \
    -i silent \
    -DINSTALLER_UI=silent \
    -DLICENSE_ACCEPTED=TRUE \
    -DUSER_INSTALL_DIR="/opt"
export CPLEX_STUDIO_BINARIES="/opt/cplex/bin/x86-64_linux/"
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
julia -e 'using Pkg; Pkg.activate("."); Pkg.instantiate();'
julia data/exp-${ID}.jl

# Save results
gsutil cp data/exp-${ID}.csv gs://blopimpute

# Delete VM
gcloud compute instances delete blopimpute --zone us-central1-a --quiet