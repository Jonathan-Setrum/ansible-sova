# This is a basic VCL configuration file for varnish.  See the vcl(7)
# man page for details on VCL syntax and semantics.
# 
# Default backend definition.  Set this to point to your content
# server.
# 
#backend defalut {
#    .host = "127.0.0.1";
#    .port = "8080";
#    .first_byte_timeout = 3600s;
#}

C{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <dirent.h>
#include <pthread.h>
#include <time.h>

#define WP_SITES_DIR        "/root/wp_sites/"
#define WP_SITES_ENABLE_DIR "/root/wp_sites/enabled/"

struct sova_cdn_hash{
  char *cdn_domain;
  char *origin_domain;
  char *ip_address;
  int expire_at;
  struct sova_cdn_hash *prev;
  struct sova_cdn_hash *next;
};

static struct sova_cdn_hash *sova_cdn_first = NULL;
static struct sova_cdn_hash *sova_cdn_last  = NULL;

pthread_mutex_t sova_mp = PTHREAD_MUTEX_INITIALIZER;

static void print_all_sova_cdn(){
  struct sova_cdn_hash *sova_cdn;
  printf("%48s, %48s, %16s, %10s, %16s, %16s \n", "CDN Domain", "Origin Domain", "IP Address", "expire_at", "prev", "next");
  for(sova_cdn = sova_cdn_first; sova_cdn != NULL; sova_cdn = sova_cdn->next){
    printf("%48s, %48s, %16s, %10d, %16p, %16p\n",
             sova_cdn->cdn_domain, sova_cdn->origin_domain, sova_cdn->ip_address,
             sova_cdn->expire_at, sova_cdn->prev, sova_cdn->next);
  }
  return;
}

static struct sova_cdn_hash *sova_cdn_malloc(char *cdn, char *origin, char *ip){
  struct sova_cdn_hash *sova_cdn = NULL;
  sova_cdn = (struct sova_cdn_hash*)malloc(sizeof(struct sova_cdn_hash));
  sova_cdn->cdn_domain    = malloc(strlen(cdn)+1);
  sova_cdn->origin_domain = malloc(strlen(origin)+1);
  sova_cdn->ip_address    = malloc(strlen(ip)+1);
  if(sova_cdn == NULL ||
     sova_cdn->cdn_domain    == NULL ||
     sova_cdn->origin_domain == NULL ||
     sova_cdn->ip_address    == NULL ){
    printf("malloc error\n");
    return NULL;
  }
  strncpy(sova_cdn->cdn_domain    , cdn, strlen(cdn)+1);
  strncpy(sova_cdn->origin_domain , origin, strlen(origin)+1);
  strncpy(sova_cdn->ip_address    , ip,  strlen(ip)+1);
  sova_cdn->expire_at = (int)time(NULL) + 300; /* 5 minutes */
  pthread_mutex_lock(&sova_mp);
  sova_cdn->prev = sova_cdn_last;
  sova_cdn->next = NULL;
  if(sova_cdn_first == NULL){
    sova_cdn_first = sova_cdn;
    sova_cdn_last = sova_cdn;
  }else if(sova_cdn_last != NULL){
    sova_cdn_last->next = sova_cdn;
    sova_cdn_last = sova_cdn;
  }
  pthread_mutex_unlock(&sova_mp);
  return sova_cdn;
}

static void sova_cdn_free(struct sova_cdn_hash *sova_cdn){
  struct sova_cdn_hash *prev;
  struct sova_cdn_hash *next;
  if(sova_cdn == NULL)return;
  pthread_mutex_lock(&sova_mp);
  free(sova_cdn->cdn_domain);
  free(sova_cdn->origin_domain);
  free(sova_cdn->ip_address);
  prev = sova_cdn->prev;
  next = sova_cdn->next;
  if(prev)prev->next = next;
  if(next)next->prev = prev;
  if(sova_cdn_first == sova_cdn ){
    sova_cdn_first = next;
  }
  if(sova_cdn_last == sova_cdn ){
    sova_cdn_last = prev;
    if(prev)prev->next = NULL;
  }
  free(sova_cdn);
  pthread_mutex_unlock(&sova_mp);
  return;
}

static struct sova_cdn_hash *find_sova_cdn_by_strage(char *cdn){
  FILE *fp;
  char *cp;
  char path[1024];
  char buf[1024];
  char *ip;
  size_t len;

  strncpy(path, WP_SITES_ENABLE_DIR, 1023);
  strncat(path, cdn, 1024 - strlen(path));
  fp = fopen(path, "r");
  if(fp == NULL){
    return NULL;
  }
  len = fread((void *)buf, 1, 1023, fp);
  buf[len] = '\0';
  cp = buf;
  while(*cp != '\0'){
    if(*cp == '\n') *cp = '\0';
    if(*cp == ':'){
      *cp = '\0';
      ip = cp+1;
    }
    cp++;
  }
  fclose(fp);
  return sova_cdn_malloc(cdn, buf, ip);
}

static struct sova_cdn_hash *find_sova_cdn(char *cdn){
  struct sova_cdn_hash *sova_cdn;
  struct sova_cdn_hash *tmp;
  int now = (int)time(NULL);
  for(sova_cdn = sova_cdn_first; sova_cdn != NULL;){
    if(now > sova_cdn->expire_at){
       tmp = sova_cdn->next;
       sova_cdn_free(sova_cdn);
       sova_cdn = tmp;
       continue; 
    }
    if(strncmp(sova_cdn->cdn_domain, cdn, strlen(cdn)) == 0){
      sova_cdn->expire_at = (int)time(NULL) + 300;
      return sova_cdn;
    }
    sova_cdn = sova_cdn->next;
  }
  return find_sova_cdn_by_strage(cdn);
}


static void sova_cdn_init(){
  char url[1024];
  DIR  *dir;
  struct dirent *dp;
  if((dir=opendir(WP_SITES_ENABLE_DIR))==NULL){
    printf("directoy open error");
    return;
  }

  for(dp=readdir(dir);dp!=NULL;dp=readdir(dir)){
    if(dp->d_type == DT_REG || dp->d_type == DT_LNK){
      find_sova_cdn_by_strage(dp->d_name);
    }
  }
  print_all_sova_cdn();

  closedir(dir);
  return;
}


}C

director default dns {
    .list = {
        .port = "80";
        .connect_timeout = 5s;
        .first_byte_timeout = 3600s;
        .between_bytes_timeout = 600s;
        .max_connections = 10000;
        "219.94.218.0"/24;
        "103.250.200.0"/22;
        "182.48.3.192"/26; # for development
        "182.48.4.48"/28; # for development
    }
    .ttl = 1m;
    .suffix = ".local";
}

acl purge {
    "localhost";
    "127.0.0.1";
}

# Below is a commented-out copy of the default VCL logic.  If you
# redefine any of these subroutines, the built-in logic will be
# appended to your code.
sub vcl_recv {
    if (req.restarts == 0) {
	if (req.http.x-forwarded-for) {
	    set req.http.X-Forwarded-For =
		req.http.X-Forwarded-For + ", " + client.ip;
	} else {
	    set req.http.X-Forwarded-For = client.ip;
	}
    }
    if (req.request != "GET" && req.request != "HEAD" && req.request != "PURGE") {
        /* CDN accepts only GET related accesses */
        error 405 "Method not allowed";
    }
    if (req.http.Authorization || req.http.Cookie) {
        /* Not cacheable by default */
        return (pass);
    }
    if (!req.url ~ "wp-(content|includes)") {
       C{
         struct sova_cdn_hash *cdn_info;
         cdn_info = find_sova_cdn(VRT_GetHdr(sp, HDR_REQ, "\005host:"));
         if(cdn_info != NULL){
           VRT_SetHdr(sp, HDR_REQ, "\005host:", cdn_info->origin_domain, vrt_magic_string_end);
         }else{
           VRT_SetHdr(sp, HDR_REQ, "\005host:", "", vrt_magic_string_end);
         }
       }C
       if (req.http.host == "") {
         error 404 "Not Found";
       } else {
         error 302 req.http.host;
       }
    }

    if (req.request == "PURGE") {
        if (!client.ip ~ purge) {
        error 405 "Not allowed.";
        }
        ban("req.url ~ "+req.url);
        error 200 "Purged";
    }
    return (lookup);
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
    return (pass);
}

sub vcl_hash {
    hash_data(req.url);
    if (req.http.host) {
        hash_data(req.http.host);
    } else {
        hash_data(server.ip);
    }
    return (hash);
}

sub vcl_hit {
    return (deliver);
}

sub vcl_miss {
    return (fetch);
}

sub vcl_fetch {
    unset beresp.http.set-cookie;
    if (req.url ~ "\.(?i)(css|js|xml)(\?.*|)$") {
      set beresp.do_gzip = true;
    }
    if (req.url ~ "\.(?i)(gif|jpg|jpeg|swf|css|js|flv|mp3|mp4|pdf|ico|png|eot|otf|svg|ttf|woff|xml)(\?.*|)$") {
       set beresp.ttl = 2h;
    }
    return(deliver);
}

sub vcl_deliver {
    return (deliver);
}

sub vcl_error {
    if(obj.status == 302){
        set obj.http.Location = "http://" + obj.response;
        return(deliver);
    } 
    set obj.http.Content-Type = "text/html; charset=utf-8";
    set obj.http.Retry-After = "5";
    synthetic {"
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <head>
    <title>"} + obj.status + " " + obj.response + {"</title>
  </head>
  <body>
    <h1>Error "} + obj.status + " " + obj.response + {"</h1>
    <p>"} + obj.response + {"</p>
    <h3>Guru Meditation:</h3>
    <p>XID: "} + req.xid + {"</p>
    <hr>
    <p>Varnish cache server</p>
  </body>
</html>
"};
    return (deliver);
}

sub vcl_init {
C{
	sova_cdn_init();
}C
	return (ok);
}

sub vcl_fini {
	return (ok);
}
