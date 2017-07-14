echo "================ Install ROS Packages from Source ==================="
echo "source /opt/ros/indigo/setup.bash" >> ~/.bashrc
source ~/.bashrc
ROS_WS=/opt/hbrain/ros_ws
mkdir -p $ROS_WS/src
cd $ROS_WS/src
git clone https://github.com/HotBlackRobotics/hbr_ros
git clone https://github.com/HotBlackRobotics/hbr_app
catkin_init_workspace

cd $ROS_WS
cd ~
echo "======================================================"

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

OROBOT_VERSION="1.0.0-beta"
echo "source /opt/ros/indigo/setup.bash" >> ~/.bashrc
echo "export OROBOT_VERSION=$OROBOT_VERSION" >> ~/.bashrc
echo "echo obrain $OROBOT_VERSION" >>  ~/.bashrc
