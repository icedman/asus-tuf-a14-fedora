# Guides
- [Fedora Installation Guide](https://asus-linux.org/guides/fedora-guide/)
- [How to Change Brightness on a Linux Laptop](https://smarttech101.com/how-change-brightness-on-a-linux-laptop)
- [Reddit | Fedora Nvidia Secure Boot](https://www.reddit.com/r/Fedora/comments/18bj1kt/fedora_nvidia_secure_boot/)

# Installation

1. **Resize Windows Partition**  
   Allocate 256GB (or any arbitrary size) for Fedora.

2. **Download Fedora Live ISO**  
   Download Fedora 41 Live ISO from [Fedora Workstation](https://fedoraproject.org/workstation/download).

3. **Burn the ISO to a USB Drive**  
   On Linux, use the following command:
   
   ```sh
   sudo cat fedora_xxx.iso > /dev/sda
   ```

4. Choose Test Fedora. Look and play around, or choose Install

5. During installation. Do custom partitions and mount ```/``` to your new partition. And mount ```/boot/EFI``` to the very first partition.

6. Go ahead and install.

# Dual Boot

Use Bios Boot menu (press ESC at starting of PC) to choose Windows or Linux.

# NVIDIA

https://docs.fedoraproject.org/en-US/fedora/latest/getting-started
If you use an NVIDIA GPU and are experiencing significant visual issues while running Fedora from a live USB,
it could be that your GPU is not fully compatible with the FOSS Nouveau driver.
One possible workaround for this situation is to do the following 3 steps:
1. During the live USB boot process, hit e at the GRUB boot menu.
2. Find the line that begins with linux, and add nouveau.modeset=0 to the end of that line.
3. ress <ctrl> + x to resume the boot process.
Follow the reddit guide above. Read especially on MOK (Machine Owner Kernel) signing.


```sh
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm 
sudo dnf upgrade --refresh 
sudo dnf install kernel-devel
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda
```

# asusctl & supergfxctl

```sh
sudo dnf copr enable lukenukem/asus-linux
sudo dnf update
sudo dnf install asusctl supergfxctl
sudo dnf update --refresh
sudo systemctl enable supergfxd.service
sudo dnf install asusctl-rog-gui
```

If asusctl or ROG Control Center only shows 'Static' as your Aura option:

```sh
sudo vim /usr/share/asusd/aura_support.ron
```

And add an entry for your system:

```sh
    (
        device_name: "FA401WV",
        product_id: "",
        layout_name: "fa401wv",
        basic_modes: [Static, Breathe, Pulse],
        basic_zones: [],
        advanced_type: None,
        power_zones: [Keyboard],
    ),
```

Update 

```sh
sudo systemctl daemon-reload 
sudo systemctl restart asusd
```

# Misc

Some of custom scripts to enable some features. Place these scripts in ```/usr/local/sbin```:

* brightness_up.sh / brightness_down.sh to control screen brightness
* remap.sh to map f4 and f5 to asusctl for aura and profile change using evsieve
* ramap-keys.service to enable ramap as a service
* save_kb.sh / restore_kb.sh save or restore keyboard led state

## Keyboard led on sleep

If your keyboard led stays on when at sleep edit ```/usr/bin/nvidia-sleep.sh```:

```sh
case "$1" in
    suspend|hibernate)
        /usr/local/sbin/save_kb.sh

x x x x

    resume)
        /usr/local/sbin/restore_kb.sh
```

## Brightness Up and Brightness down keys

If the keys (f6 and f7) are not functioning:

```snd dnf install acpid```

Run acpi_listen to verify the events triggered when f6 and f7 are pressed

```acpi_listen```

Edit or add the file ```/etc/acpi/events/brightness_up```
```sh
event=video/brightnessup BRTUP 00000086 00000000
action=/etc/acpi/actions/brightness_up.sh
```

```sh
Edit or add the file ```/etc/acpi/events/brightness_down```
event=video/brightnessdown BRTDN 00000087 00000000
action=/etc/acpi/actions/brightness_down.sh
```

Copy the brightness scripts to ```/etc/acpi/actions/```. Reboot or restart ```acpid```


## supergfxctl

Change gpu with these commands:

```sh
supergfxctl -m Integrated
supergfxctl -m Hybrid
```

***Warning***

Switching to ```Integrated``` might mess up the drivers and you'll boot into a black screen. Just change TTY (CTRL+ALT+F4) and switch back to ```Hybrid```

You'll have to build supergfxctl yourself. Follow the asus-linux guide. And you'll have to patch the code before compiling at around line 324 of ```src/pci_device.rs```:

```patch
-                                let hwmon_n_opt = match dev_path.read_dir() {
-                                    Ok(mut entries) => {
-                                        entries.next()
-                                    } Err(_e) => {
-                                        // debug!("Error reading hwmon directory: {}", e.to_string());
-                                        None // Continue with the assumption it's not a dGPU
-                                    }
-                                };
+                                let hwmon_n_opt = dev_path.read_dir().map_err(
+                                    |e| GfxError::from_io(e, dev_path)
+                                )?.next();
```

## suppress some messages when running Integrated gpu

```sh
sudo systemctl mask nvidia-fallback.service
```

## updating

Nvidia often doesn't get updated correctly. Force akmods

```sh
sudo akmods --force --kernel "$(uname -r)"
```
then

```sh
sudo dracut --force
```
## suspend fails with external monitor

Laptop instant-wakes after suspend

```sh
sudo grubby --update-kernel=ALL --args='gpiolib_acpi.ignore_interrupt=AMDI0030:00@24 acpi_backlight=vendor'
```

Above show pin 24 will be ignored as it causes the instant wake - when monitor is attached.

To find the cause of instant wake:

```sh
sudo sh -c 'echo 1 > /sys/power/pm_debug_messages'
systemctl suspend
sudo dmesg
```

IRQ 7 causes the wake

```sh
sudo dmesg | grep GPIO
```

This will return GPIO 24 is active

[Source](https://wiki.archlinux.org/title/Power_management/Wakeup_triggers#Ryzen_7000_Series) 

## Rabit holes

* This laptop doesn't support s3 (deep sleep). Stop trying to force s3 - just to fix instant wake.
