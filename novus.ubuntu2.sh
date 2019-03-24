cd $HOME/novus.mac
source lib/util

sudo mount -a

log_header "Docker Login:"
docker login gitlab-master.nvidia.com:5005 -u amago

cd $HOME/ai
source ~/.bash_profile

dazel build //moduluspy/...
dazel run //moduluspy:build_wheel -- $(pwd)/wheel_output
pip install --user ./wheel_output/*.whl \
            --find-links=https://archives.nvda.ai/pypi/nvidiaapis/index.html \
            --find-links=https://archives.nvda.ai/pypi/maglev/index.html

pip uninstall tensorflow-gpu 
pip uninstall numpy
pip uninstall numpy
pip install tf-nightly-gpu numpy 
pip install horovod

prompt "Confirm it all worked? (will delete ./wheel_output/)"

rm -rf ./wheel_output/

dgx config set -s compute.nvidia.com -k pEOdfrCxnSEUGdtLF3SFttstM3d7hGWBazYQvAEX
docker login -u "\$oauthtoken" nvcr.io -p pEOdfrCxnSEUGdtLF3SFttstM3d7hGWBazYQvAEX

dgx project set 40

cd $HOME/sdk/build_x86
cmake -DCMAKE_BUILD_TYPE=Release .. -DCMAKE_C_COMPILER=gcc-4.9 -DCMAKE_CXX_COMPILER=g++-4.9 -G "Ninja"
ninja -j12
ninja install -j12