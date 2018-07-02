# Manual install steps

## Disable gnome ssh-agent

```
sudo sed -i 's/use-ssh-agent/#\0/g' /etc/X11/Xsession.options
```
