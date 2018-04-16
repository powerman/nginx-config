server {
	listen 80;

	server_name example.com www.example.com;

	include conf.d/opt/letsencrypt.conf;

	return 301 https://$server_name$request_uri;
}

server {
	listen 443 ssl http2;

	server_name example.com www.example.com;

	ssl_certificate     /etc/letsencrypt/live/example.com/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
	include conf.d/opt/letsencrypt.conf;

	include conf.d/opt/www_redirect.conf;

	# include conf.d/opt/tcp_latency.conf;
	### OR
	# include conf.d/opt/tcp_throughput.conf;

	root /var/www/$server_name;

	expires $expires;

	include conf.d/opt/protect_system_files.conf;
	include conf.d/opt/cache_busting.conf;

	location ~ (\.html|/)$ {
		# include conf.d/opt/fastcgi_apache.conf;
		fastcgi_pass unix:/var/www/$server_name/.fastcgi.sock;
	}
}
