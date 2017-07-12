# Helper makefile to demonstrate the use of the rpi-emu docker environment
# This is mostly useful for development and extension as part of an image builder
#
# For an example using this in a project, see Makefile.example

DATE=2016-05-27

DIST=$(DATE)-raspbian-jessie-lite
ZIP=$(DIST).zip
IMAGE=$(DIST).img

DL_PATH=http://vx2-downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2016-05-31/$(ZIP)
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
	@echo "Pulling Raspbian image"
	@mkdir -p images
	wget -O images/$(ZIP) -c $(DL_PATH)
	@unzip -d images/ images/$(ZIP)
	@touch $@

# Expand the image by a specified size
# TODO: implement expand script to detect partition sizes
expand: build bootstrap
	dd if=/dev/zero bs=1m count=1024 >> images/$(IMAGE)
	@docker run $(RUN_ARGS) ./expand.sh images/$(IMAGE) 1024

shrink: build bootstrap
	@docker run $(RUN_ARGS) /bin/bash -c 'pishrink images/$(IMAGE)'

images/hbrain_dev_0.img:
		@cp images/$(IMAGE) images/tmp.img
		@dd if=/dev/zero bs=1m count=1024 >> images/tmp.img
		@echo Copying files
		@docker run $(RUN_ARGS) /bin/bash -c 'mkdir $(MOUNT_DIR) && \
											./mount.sh images/tmp.img $(MOUNT_DIR) && \
											cp -Rvf /usr/rpi/resources $(MOUNT_DIR)/opt/; \
											./unmount.sh $(MOUNT_DIR)'

		@docker run $(RUN_ARGS) ./expand.sh images/tmp.img 1024
		@docker run $(RUN_ARGS) /bin/bash -c './run.sh images/tmp.img "/bin/bash /opt/resources/00_hbrain_setup.sh"'
		@docker run $(RUN_ARGS) /bin/bash -c 'pishrink images/tmp.img'
		@mv images/tmp.img images/hbrain_dev_0.img

images/hbrain_dev_1.img: images/hbrain_dev_0.img build
	  @cp images/hbrain_dev_0.img images/tmp.img
		@dd if=/dev/zero bs=1m count=1024 >> images/tmp.img
		@echo Copying files
		@docker run $(RUN_ARGS) /bin/bash -c 'mkdir $(MOUNT_DIR) && \
											./mount.sh images/tmp.img $(MOUNT_DIR) && \
											cp -Rvf /usr/rpi/resources $(MOUNT_DIR)/opt/; \
											./unmount.sh $(MOUNT_DIR)'
		@docker run $(RUN_ARGS) ./expand.sh images/tmp.img 1024
		@docker run $(RUN_ARGS) /bin/bash -c './run.sh images/tmp.img "/bin/bash /opt/resources/01_hbrain_setup.sh"'
		@docker run $(RUN_ARGS) /bin/bash -c 'pishrink images/tmp.img'
		@mv images/tmp.img images/hbrain_dev_1.img

# Launch the docker image without running any of the utility scripts
run: build bootstrap
	@echo "Launching interactive docker session"
	@docker run $(RUN_ARGS) /bin/bash

# Launch the docker image into an emulated session
run-emu: build
	@echo "Launching interactive emulated session"
	@docker run $(RUN_ARGS) /bin/bash -c './run.sh images/hbrain_dev_1.img'

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
