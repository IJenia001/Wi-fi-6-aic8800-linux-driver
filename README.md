# Wi-fi-6-aic8800-linux-driver

cd "/home/name_folder/DRIVER wifi6"
sudo make install
sudo modprobe -r aic8800_fdrv aic_load_fw 2>/dev/null || true
sudo modprobe aic_load_fw
sudo modprobe aic8800_fdrv
