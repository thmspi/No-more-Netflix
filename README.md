# No more Netflix

In order to initialize your new stack properly, here is what you need to run from your **home directory** as your normal user :

```bash
sudo apt update && sudo apt install -y git
git clone https://github.com/thmspi/No-more-Netflix.git
cd No-more-Netflix
chmod +x ubuntu-server-setup.sh
./ubuntu-server-setup.sh
```

## Access yours services :

You can access all of your services from thoses adress : 

- **Radarr** : <SERVER_IP>:7878
- **Sonarr** : <SERVER_IP>:8989
- **Prowlarr** : <SERVER_IP>:9696
- **Transmission** : <SERVER_IP>:8118
- **Bazarr** : <SERVER_IP>:6767
- **Radarr** : <SERVER_IP>:32400/web

