echo "================ Upgrade env ================"
apt-get update
apt-get upgrade -y
apt-get install git -y

echo "================ Installing ROS Indigo ================"
sh -c 'echo "deb http://packages.ros.org/ros/ubuntu trusty main" > /etc/apt/sources.list.d/ros-latest.list'
apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
apt-get update
apt-get install ros-indigo-ros-base -y
apt-get install ros-indigo-rosbridge-suite ros-indigo-rosserial-server -y
echo "================ ROS Indigo Installed ================"

echo "================ Install ROS Packages from Source ==================="
source /opt/ros/indigo/setup.bash
TMP_ROS_WS=/opt/hbrain/ros_ws_tmp
mkdir -p $TMP_ROS_WS/src
cd $TMP_ROS_WS/src
catkin_init_workspace
echo "================ Camera Configuration ================"
apt-get install ros-indigo-camera-info-manager ros-indigo-async-web-server-cpp ros-indigo-compressed-image-transport ros-indigo-theora-image-transport -y
git clone https://github.com/RobotWebTools/web_video_server
git clone https://github.com/fpasteau/raspicam_node.git
git clone https://github.com/ros-drivers/usb_cam
git clone https://github.com/HotBlackRobotics/hb_core_msgs
cd $TMP_ROS_WS
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_calib3d.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_calib3d.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_contrib.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_contrib.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_core.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_core.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_features2d.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_features2d.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_flann.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_flann.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_gpu.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_gpu.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_highgui.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_highgui.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_imgproc.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_imgproc.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_legacy.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_legacy.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_ml.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_ml.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_objdetect.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_objdetect.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_ocl.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_ocl.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_photo.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_photo.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_stitching.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_stitching.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_superres.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_superres.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_ts.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_ts.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_video.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_video.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/libopencv_videostab.so.2.4.9 /usr/lib/arm-linux-gnueabihf/libopencv_videostab.so.2.4.8
ln -s /usr/lib/arm-linux-gnueabihf/liblog4cxx.so /usr/lib/liblog4cxx.so
catkin_make && catkin_make install -DCMAKE_INSTALL_PREFIX=/opt/ros/indigo
cd ~
rm -rf $TMP_ROS_WS
echo "======================================================"

echo "================ Install ROS Packages from Source ==================="
source ~/.bashrc
ROS_WS=/opt/hbrain/ros_ws
mkdir -p $ROS_WS/src
cd $ROS_WS/src
catkin_init_workspace

cd $ROS_WS
cd ~
echo "======================================================"

HBRAIN_VERSION="0.6.0-beta"
echo "source /opt/ros/indigo/setup.bash" >> ~/.bashrc
echo "export HBRAIN_VERSION=$HBRAIN_VERSION" >> ~/.bashrc
echo "cat /opt/resources/art.txt" >> ~/.bashrc
echo "echo hbrain $HBRAIN_VERSION" >>  ~/.bashrc
