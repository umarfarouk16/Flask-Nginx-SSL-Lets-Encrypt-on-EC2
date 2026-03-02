## Project1: A static webpage hosted on AWS infra

## Basic specifications:
```
> A domain which directs to a webpage about author
> It will run on Flask/Nginx
> It will have an SSL certificate for secure connection
```

## To test on local setup:

1. Install Flask using python virtual environment
```bash
source .venv/bin/activate
pip3 install -r requirements.txt
```

2. Run the application:
```bash
python app.py
```
3. Access the site at `http://localhost:8000`

[alt text](<Screenshot 2026-03-02 at 4.35.07 AM.png>)

## EC2 Deployment

### Prerequisites
- EC2 instance with Ubuntu
- Public IP: `100.52.168.5`
- Internet GW / Security group (with port 80/8000/22/443) attached to the EC2 instance
- Python3/Git installed
```bash
sudo apt update && sudo apt upgrade -y
sudo add-apt-repository universe -y
sudo apt update
sudo apt install git nginx python3 python3-pip python3-venv -y
```

### Setup Steps:

#### Use Flask as the only web server: (Development grade)
1. Connect to EC2 instance and clone your public repo
```bash
ssh -i ~/.ssh/cyberkey.pem ubuntu@100.52.168.5
git clone https://github.com/umarfarouk16/Flask-Nginx-SSL-Lets-Encrypt-on-EC2
```

2. Update executable permissions
```bash
chmod +x setup_venv.sh
```

3. Comment out the nginx line in setup_venv.sh
```
# nginx -g "daemon off;"
```

4. Install Flask and gunicorn packages using
```bash
./setup_venv.sh
```

5. **Run the Flask app:**
```bash
python3 app.py
```

6. Access the site at `http://100.52.168.5:8000`


![Flask on port :8000](./ash-web/images/using_flask_on_8000.jpg)

### Use Nginx as reverse proxy server (Production grade)

1. Copy nginx config:
```bash
sudo cp nginx.conf /etc/nginx/sites-available/portfolio
sudo ln -s /etc/nginx/sites-available/portfolio /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
```

2. nginx.conf should contain:
```
server {
    listen 80;
    server_name umarfkporfolio.website www.umarfkporfolio.website;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /static/ {
        alias /home/ubuntu/portfolio/static/;
        expires 30d;
    }
}
```

3. **Start Nginx:**
```bash
sudo nginx -t
sudo systemctl enable nginx
sudo systemctl start nginx
```

4. Access the site at `http://umarfkporfolio.website`

![Nginx without SSL:](./ash-web/images/using_nginx_without_ssl.jpg)

### Security Group Configuration

Make sure EC2 security group allows:
- Port 22 (SSH)
- Port 80 (HTTP) from anywhere (0.0.0.0/0)
- Port 443 (HTTPS) from anywhere (0.0.0.0/0)
- Port 8000 if accessing Flask directly (or remove if using Nginx)

## Troubleshooting

1. **Port already in use:**
```bash
sudo lsof -i :8000
sudo kill -9 <PID>
```

2. **Permission issues:**
```bash
chmod +x setup_venv.sh
```

## SSL Cert installation using Certbot for Secure connection
(AWS Cert manager does not issue SSL Cert for EC2 instances on a free tier account)

### Before getting the cert, get domain name ready and assign an "A" record to EC2's public IP in Route53 service of AWS.

- Record type: **A**
- Name: `umarfkporfolio.website`
- Value: `100.52.168.5`

1. Install Certbot via snap (recommended):
```bash
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

2. Make sure nginx.conf has your domain set:
```
server_name umarfkporfolio.website www.umarfkporfolio.website;
```

3. Test and restart Nginx:
```bash
sudo nginx -t
sudo systemctl restart nginx
```

4. Get SSL Certificate (Certbot will automatically configure Nginx):
```bash
sudo certbot --nginx -d umarfkporfolio.website -d www.umarfkporfolio.website
```

5. Follow the prompts to enter your email and agree to terms.
6. Update Security group to allow HTTPS traffic on Port 443 from 0.0.0.0/0
7. Verify secure site access: `https://umarfkporfolio.website`

8. Auto-renew SSL (verify it works):
```bash
sudo certbot renew --dry-run
```

![Nginx with SSL:](./ash-web/images/using_nginx_with_SSL.jpg)
