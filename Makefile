# Helper makefile to demonstrate the use of the rpi-emu docker environment
# This is mostly useful for development and extension as part of an image builder
#
# For an example using this in a project, see Makefile.example


TAR=minibian.zip
IMAGE=2016-03-12-jessie-minibian.img

DL_PATH=https://sourceforge.net/projects/minibian/files/latest/download
CWD=$(shell pwd)

# Docker arguments
# Interactive mode, remove container after running, privileged mode for loopback access
# Mount images to /usr/rpi/images to access image files from container
# Change working directory to /usr/rpi (which is loaded with the helper scripts)
RUN_ARGS=-it --rm --privileged=true -v $(CWD)/images:/usr/rpi/images -w /usr/rpi ryankurte/docker-rpi-emu
MOUNT_DIR=/media/rpi

# Build the docker image
build:
	@echo "Building base docker image"
	@docker build -t ryankurte/docker-rpi-emu .

# Bootstrap a RPI image into the images directory
bootstrap: images/$(IMAGE)

# Fetch the RPI image from the path above
images/$(IMAGE):
	wget -o images/$(TAR) $(IMAGE)
	tar -xf images/$(TAR)

# Expand the image by a specified size
# TODO: implement expand script to detect partition sizes
expand: build bootstrap
	dd if=/dev/zero bs=1m count=1024 >> images/$(IMAGE)
	@docker run $(RUN_ARGS) ./expand.sh images/$(IMAGE) 1024

shrink: build bootstrap
	@docker run $(RUN_ARGS) /bin/bash -c 'pishrink images/$(IMAGE)'

# Launch the docker image without running any of the utility scripts
run: build bootstrap
	@echo "Launching interactive docker session"
	@docker run $(RUN_ARGS) /bin/bash

# Launch the docker image into an emulated session
run-emu: build bootstrap
	@echo "Launching interactive emulated session"
	@docker run $(RUN_ARGS) /bin/bash -c './run.sh images/$(IMAGE)'

setup-emu: copy build bootstrap expand
	@docker run $(RUN_ARGS) /bin/bash -c './run.sh images/$(IMAGE) "/bin/bash /opt/resources/setup.sh"'

	# Copy files from local resources directory into image /usr/resources
	# Note that the resources directory is mapped to the container as a volume in the RUN_ARGS variable above
copy: build bootstrap
	@echo Copying files
	@docker run $(RUN_ARGS) /bin/bash -c 'mkdir $(MOUNT_DIR) && \
										./mount.sh images/$(IMAGE) $(MOUNT_DIR) && \
										cp -Rv /usr/rpi/resources $(MOUNT_DIR)/opt/; \
										./unmount.sh $(MOUNT_DIR)'


test: build bootstrap
	@echo "Running test command"
	@docker run $(RUN_ARGS) /bin/bash -c './run.sh images/$(IMAGE) "uname -a"'
