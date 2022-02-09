vcl 4.0;

include "backend.vcl";

acl purge_ips {
    "localhost";
    "127.0.0.1";
}

# Below is a commented-out copy of the default VCL logic.  If you
# redefine any of these subroutines, the built-in logic will be
# appended to your code.
sub vcl_recv {
    if (req.method == "PURGE") {
        if (!client.ip ~ purge_ips) {
          return (synth(405, "Not Allowed."));
        }
        ban("obj.http.x-cache-host ~ " + req.http.host);
        return(purge);
    }
    if (req.method != "GET" && req.method != "HEAD" && req.method != "PURGE") {
        /* CDN accepts only GET related accesses */
        return (synth(405, "Not Allowed."));
    }
    if (req.http.Authorization || req.http.Cookie) {
        /* Not cacheable by default */
        return (pass);
    }
    if (!req.url ~ "wp-(content|includes)") {
      return (synth(403, "Forbidden."));
    }

    return (hash);
}

sub vcl_pipe {
    # Note that only the first request to the backend will have
    # X-Forwarded-For set.  If you use X-Forwarded-For and want to
    # have it set for all requests, make sure to have:
    # set bereq.http.connection = "close";
    # here.  It is not set by default as it might break some broken web
    # applications, like IIS with NTLM authentication.
    return (pipe);
}

sub vcl_pass {
    return (fetch);
}

sub vcl_hash {
    hash_data(req.url);
    if (req.http.host) {
        hash_data(req.http.host);
    } else {
        hash_data(server.ip);
    }
    return (lookup);
}

sub vcl_hit {
    if (obj.ttl >= 0s) {
        // A pure unadultered hit, deliver it
        return (deliver);
    }
    if (obj.ttl + obj.grace > 0s) {
        // Object is in grace, deliver it
        // Automatically triggers a background fetch
        return (deliver);
    }
    // fetch & deliver once we get the result
    return (fetch);
}

sub vcl_miss {
    return (fetch);
}

sub vcl_backend_response {
    if(beresp.status == 404){
      set beresp.uncacheable = false;
      set beresp.ttl = 10m;
      return(deliver);
    }
    if(beresp.status != 200 && beresp.status != 301){
      set beresp.uncacheable = true;
      set beresp.ttl = 10m;
      return(deliver);
    }
    unset beresp.http.set-cookie;
    if (bereq.url ~ "\.(?i)(txt|css|js|xml)(\?.*|)$") {
      set beresp.do_gzip = true;
    }
    if (bereq.url ~ "\.(?i)(txt|gif|jpg|jpeg|swf|css|js|flv|mp3|mp4|pdf|ico|png|eot|otf|svg|ttf|woff|xml)(\?.*|)$") {
      set beresp.uncacheable = false;
      set beresp.ttl = 2h;
    } else {
      set beresp.uncacheable = true;
      set beresp.ttl = 10m;
      return(deliver);
    }
    set beresp.http.x-cache-host = bereq.http.host;
    return(deliver);
}

sub vcl_deliver {
    unset resp.http.x-cache-host;
    unset resp.http.x-origin-host;
    return (deliver);
}

sub vcl_purge {
    return (synth(200, "Purged"));
}

sub vcl_synth {
    if(resp.status == 302){
        set resp.http.Location = "http://" + req.http.x-origin-host;
        return(deliver);
    }
    set resp.http.Content-Type = "text/html; charset=utf-8";
    set resp.http.Retry-After = "5";
    synthetic({"<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <head>
    <title>"} + resp.status + " " + resp.reason + {"</title>
  </head>
  <body>
    <h1>Error "} + resp.status + " " + resp.reason + {"</h1>
    <p>"} + resp.reason + {"</p>
    <hr>
     <p>SovaWP CDN server</p>
  </body>
</html>"});
    return (deliver);
}

sub vcl_backend_error {
    set beresp.http.Content-Type = "text/html; charset=utf-8";
    set beresp.http.Retry-After = "5";
    synthetic( {"<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <head>
    <title>"} + beresp.status + " " + beresp.reason + {"</title>
  </head>
  <body>
    <h1>Error "} + beresp.status + " " + beresp.reason + {"</h1>
    <p>"} + beresp.reason + {"</p>
    <hr>
    <p>SovaWP CDN server</p>
  </body>
</html>"});
    return(deliver);
}

sub vcl_init {
  return (ok);
}

sub vcl_fini {
  return (ok);
}
