#!/bin/bash
dnf update -y
dnf install -y nginx

cat > /usr/share/nginx/html/index.html <<EOF
<html>
  <head><title>App is running</title></head>
  <body>
    <h1>Application is running</h1>
    <p>Hostname: $(hostname)</p>
  </body>
</html>
EOF

systemctl enable nginx
systemctl start nginx