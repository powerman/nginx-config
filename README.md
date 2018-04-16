# nginx-config

Nginx boilerplate config.

Inspired by (and include a couple of files from) [H5BP Nginx Server
Configs](https://github.com/h5bp/server-configs-nginx).

- Support only HTTPS (force it using HSTS):
  - HTTP on front-end server is used only to respond to Let's Encrypt and
    redirect to HTTPS.
- Redirect from www to non-www (whenever possible and makes sense).
- Secure defaults.
- Improved MIME types support.
- Designed for ease microservice development:
  - Good support for proxy and fastcgi backends.
  - Ready to run as main website using Let's Encrypt certificate.
  - Ready to run behind HTTPS-terminating proxy (like AWS ELB).
  - Ready to run locally in a Docker using local CA certificate.
  - Ready to run as main website in a LAN using local CA certificate.
- No optimizations for high load (yet).

## Setup

Require nginx-1.11.8 or newer.

1. Replace contents of your `/etc/nginx/` with files from this repo.
2. Use files in `sites-available/` as templates for your websites.
3. Make symlinks in `sites-enabled/` to `../sites-available/SOME_CONFIG`.

You may need to [securely setup HTTPS certificates for local/staging
environment](https://gist.github.com/powerman/060a6e10d3c901fa5c4085c166a51c03)
and copy them into `ssl/`, plus generate `ssl/dhparam.pem`:
```sh
openssl dhparam 2048 > ssl/dhparam.pem
```

To run in a docker you may want to set local resolver in
[conf.d/resolver.conf](conf.d/resolver.conf) and logging to stderr/stdout
in [nginx.conf](nginx.conf).

## Usage

**Feel free to change any files as you like to.**

Usually you're supposed to have in `sites-enabled/` one symlink to either
`../sites-available/default` or `../sites-available/no_default` - as
"catch-all" config which defines behaviour for unknown host names, plus
any amount of symlinks to individual website config (like
`../sites-available/example.*`).

- [sites-available/no_default](sites-available/no_default) - serve any
  host name by closing connection without sending any response.
  - Recommended as default secure behaviour.
- [sites-available/default](sites-available/default) - serve any host name
  "as is" (without HTTP to HTTPS and www to non-www redirects).
  - May be useful to quickly serve same content for any host name, using
    both HTTP and HTTPS.
- [sites-available/example.com](sites-available/example.com) is a public
  HTTPS website using Let's Encrypt certificate, with HTTP to HTTPS and
  www to non-www redirects.
- [sites-available/example.lan](sites-available/example.lan) is same as
  `example.com` except runs in LAN using self-signed certificate.
  - You may need to set your LAN networks in
    [conf.d/opt/protect_local_sites.conf](conf.d/opt/protect_local_sites.conf).
- [sites-available/example.com_backend](sites-available/example.com_backend)
  is supposed to run on back end, behind some frond-end proxy/load
  balancer (like AWS ELB) which is expected to terminate HTTPS and forward
  user request to back end by HTTP. As usually, it redirects HTTP to HTTPS
  (using headers from frond-end proxy to detect scheme of user request)
  and www to non-www.
- [sites-available/example.com_docker](sites-available/example.com_docker)
  is supposed to run in a docker on your workstation or by CI service.
  While it's supposed to work like `example.com` it doesn't know which
  host name and port user have to use to connect to this docker container,
  thus it can't do usual redirects. It provides only HTTPS using
  self-signed certificate.
- `include conf.d/opt/*` lines in each file are optional, but usually
  makes sense for that type of example file.
- `location {}` section in these files show example how to pass requests
  to back-end webservice or fastcgi service.
- If you're going to use any of listed below directives you'll probably
  have to also re-`include` related files, otherwise your directives will
  replace directives in these files (which may be desired behaviour):
  - `add_header`: `include conf.d/headers.conf;`
  - `proxy_set_header`: `include conf.d/proxy.conf;`
  - `fastcgi_param`: `include conf.d/opt/fastcgi_apache.conf;` or `include
    conf.d/fastcgi.conf;`
