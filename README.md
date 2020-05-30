README
======

Autologin
---------

1. Install lightdm:

        # pacman -Sy lightdm

2. Enable lightdm at bootup:

        # systemctl enable lightdm.service

3. Enable autologin at bootup:

   Edit the LightDM configuration file and ensure these lines are uncommented and correctly configured:

        # cat /etc/lightdm/lightdm.conf
        [Seat:*]
        autologin-user=username

   You must be part of the autologin group to be able to login automatically without entering your password:

        # groupadd -r autologin
        # gpasswd -a username autologin
