#! /bin/bash
sudo apt update

# Install JRE 2:1.11-72
sudo apt --assume-yes install default-jre=2:1.11-72

# Install CPLEX 12.10
gsutil cp gs://cplex-1210/cplex-1210.bin cplex-1210.bin
chmod +x cplex-1210.bin
CPLEX_DIR="/opt/ibm/ILOG/CPLEX_Studio_Community1210"
sudo ./cplex-1210.bin \
    -i silent \
    -DINSTALLER_UI=silent \
    -DLICENSE_ACCEPTED=TRUE \
    -DUSER_INSTALL_DIR=${CPLEX_DIR}
export CPLEX_STUDIO_BINARIES="${CPLEX_DIR}/cplex/bin/x86-64_linux/"
rm -rf cplex-1210.bin

# Install Julia 1.5.3
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