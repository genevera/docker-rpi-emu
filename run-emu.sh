docker run -it --rm --privileged=true -v $(PWD)/images:/usr/rpi/images -w /usr/rpi ryankurte/docker-rpi-emu /bin/bash -c "./run.sh ${1}"
