# Guides
- [Fedora Installation Guide](https://asus-linux.org/guides/fedora-guide/)
- [How to Change Brightness on a Linux Laptop](https://smarttech101.com/how-change-brightness-on-a-linux-laptop)
- [Reddit | Fedora Nvidia Secure Boot] (https://www.reddit.com/r/Fedora/comments/18bj1kt/fedora_nvidia_secure_boot/)

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

Follow the reddit guide above. Read especially on MOK (Machine Owner Kernel) signing.

```sh
sudo dnf install \   https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 
sudo dnf install \   https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm 
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

# Brightness Up and Brightness down keys

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


# supergfxctl

Change gpu with these commands:

```sh
supergfxctl -m Integrated
supergfxctl -m Hybrid
```

***Warning***

Switching to ```Integrated``` might mess up the drivers and you'll boot into black screen. Just change TTY (CTRL+ALT+F4) and switch book to ```Hybrid```

You'll have to build supergfxctl yourself. Follow the asus-linux guide. And you'll have to patch the code before compiling at around line 324:

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

# suppress some messages when running Integrated gpu

```sh
sudo systemctl mask nvidia-fallback.service
```