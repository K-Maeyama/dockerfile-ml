docker run --gpus '"device=0"' -it --shm-size 16G --privileged -p 8888:8888 -p 5900:5900 -p 6006:6006 -p 8265:8265 -v /data1/e-maeyama/sharespace:/root/sharespace --rm $1 
