import requests
import hashlib
import os

ANSIBLE_FILE = "ansible_config.txt"

def package_info(locale):
    # http**s** returns more packages than http.
    url = "https://api.wordpress.org/core/version-check/1.7/?local_package={locale}&locale={locale}".format(locale=locale)
    json = requests.get(url).json()
    for package in json["offers"]:
        if package["locale"] == locale:
            package_url = package["download"]
            version = package["version"]
            package_name = locale + "-" + os.path.basename(package_url)
            return [package_url, package_name, version]
    raise Exception("latest package for {0} is not released yet.  Edit ansible file manually".format(locale))

def plugin_package_info(name):
    try:
        url = "https://api.wordpress.org/plugins/info/1.0/{name}.json".format(name=name)
        json = requests.get(url).json()
        package_url = json["download_link"]
        package_name = os.path.basename(package_url)
        return package_name
    except TypeError:
        if json is None:
            raise Exception("{0} not found on WP repository".format(name))

def oldvalue(needle):
    f = open("ansible/group_vars/all")
    for line in f:
        if line.find(needle) >= 0:
            return line.strip().split(": ")[1]

def generate_config():
    en_wp_download_link, en_wp_package_name, en_wp_version = package_info("en_US")
    try:
        ja_wp_download_link, ja_wp_package_name, ja_wp_version = package_info("ja")
    except:
        ja_wp_download_link = oldvalue("wp_package_ja")
        ja_wp_package_name  = oldvalue("wp_zip_ja")
        ja_wp_version       = oldvalue("wp_version_ja")

    template = """# BEGIN WordPress

# wordpress package url
wp_package_ja: {wp_package_ja}
wp_package_en: {wp_package_en}

wp_version_ja: {wp_version_ja}
wp_version_en: {wp_version_en}

# wordpress
wp_url: http://wordpress.org/
wp_zip_ja: {wp_zip_ja}
wp_zip_en: {wp_zip_en}

# plugin
wp_plugin_url: https://downloads.wordpress.org/plugin/
varnish_http_purge: {varnish_http_purge}
wp_multibyte_patch: {wp_multibyte_patch}
wp_updates_notifier: {wp_updates_notifier}
akismet: {akismet}

# END WordPress
"""
    result = template.format(
            wp_package_ja=ja_wp_download_link,
            wp_zip_ja=ja_wp_package_name,
            wp_version_ja=ja_wp_version,
            wp_package_en=en_wp_download_link,
            wp_zip_en=en_wp_package_name,
            wp_version_en=en_wp_version,
            varnish_http_purge=plugin_package_info("varnish-http-purge"),
            wp_multibyte_patch=plugin_package_info("wp-multibyte-patch"),
            wp_updates_notifier=plugin_package_info("wp-updates-notifier"),
            akismet=plugin_package_info("akismet")
            )
    with open(ANSIBLE_FILE,"wt") as f:
        f.write(result)


def md5_of_file(filename):
    if os.path.isfile(filename):
        return hashlib.md5(open(filename, 'rb').read()).hexdigest()
    else:
        return ""

if __name__ == "__main__":
    generate_config()
