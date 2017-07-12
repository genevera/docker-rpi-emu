
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



apt-get install hostapd isc-dhcp-server cron -y
apt-get install python-pip python-virtualenv -y
update-rc.d -f isc-dhcp-server remove
update-rc.d -f hostapd remove

echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"" >> /etc/default/hostapd

MYPATH="/root"
cd $MYPATH
git clone https://github.com/HotBlackRobotics/raspberry-autowifi
cd raspberry-autowifi
virtualenv env && source env/bin/activate && pip install -r requirements.txt
cp -f $MYPATH/raspberry-autowifi/configs/interfaces /etc/network/interfaces
cp -f $MYPATH/raspberry-autowifi/configs/dhcpd.conf /etc/dhcp/dhcpd.conf
cp $MYPATH/raspberry-autowifi/configs/hostapd.conf /etc/hostapd/

crontab -l > mycron
echo "@reboot $MYPATH/raspberry-autowifi/env/bin/python /root/raspberry-autowifi/scripts/autowifi.py >> /var/log/wifi_auto.log" >> mycron
crontab mycron
rm mycron
update-rc.d cron defaults

echo "[Service]" >> /lib/systemd/system/networking.service.d/network-pre.conf
echo "TimeoutStartSec=1" >> /lib/systemd/system/networking.service.d/network-pre.conf
