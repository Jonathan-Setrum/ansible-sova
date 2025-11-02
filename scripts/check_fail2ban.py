#coding:utf-8
import requests
from tqdm import tqdm

payload = {'key1': 'value1', 'key2': 'value2'}

user_agents = [
"Jetpack by WordPress.com",
"MarsEdit",
"Mozilla/4.0 (compatible; MSIE 9.11; Windows NT 6.1; Windows Live Writer 1.0)",
"SLPRO%20Blog%20Editor/4.0.4 CFNetwork/711.0.6 Darwin/14.0.0",
"wp-iphone/4.4 (iPhone OS 8.1, iPhone) Mobile",
"wp-android/3.2 (Android 4.4.4; ja_JP; LGE Nexus 5/hammerhead)",
"python"
]

HOST = '182.48.3.227'
for user_agent in user_agents:
    print(user_agent)
    for a in tqdm(range(21)):
        #r = requests.post("http://" + HOST + "/wp-login.php", headers={'User-Agent':user_agent})
        #r = requests.post("http://" + HOST + "/wp-comments-post.php", headers={'User-Agent':user_agent})
        #r = requests.post("http://" + HOST + "/wp-trackback.php", headers={'User-Agent':user_agent})
        r = requests.post("http://" + HOST + "/xmlrpc.php", headers={'User-Agent':user_agent})
