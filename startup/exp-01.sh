#! /bin/bash
git clone https://github.com/igutierrezm/BLOPimpute-experiments.git
cd BLOPimpute-experiments
source install.sh
julia src/exp-01.jl
gsutil cp data/exp-01.csv gs://rivera2021-db/exp-01.csv
gcloud compute instances stop rivera2021-vm --zone us-central1-a