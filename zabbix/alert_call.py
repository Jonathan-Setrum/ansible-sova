#!/usr/bin/python
import os, yaml
from twilio.rest import TwilioRestClient
from datetime import date, time, datetime
from gmail import *
current_dir = os.path.dirname(__file__)


def call(phone_number):

    TWILIO_ACCOUNT = yaml.load(open(os.path.join(current_dir,'twilio.yml')).read().decode('utf-8'))
    ACCOUNT_SID = TWILIO_ACCOUNT['ACCOUNT_SID']
    AUTH_TOKEN = TWILIO_ACCOUNT['AUTH_TOKEN']
    PHONE_NUMBER = TWILIO_ACCOUNT['PHONE_NUMBER']

    client = TwilioRestClient(ACCOUNT_SID, AUTH_TOKEN)
    call = client.calls.create(
      to=phone_number,#ex) +815036331292
      from_=PHONE_NUMBER,
      url="http://twimlets.com/echo?Twiml=%3CResponse%3E%0A%20%20%20%20%3CSay%20voice%3D%22alice%22%20language%3D%22ja-JP%22%3E%E3%82%84%E3%81%B0%E3%81%84%E3%80%82%E3%80%80%E3%81%9D%E3%81%B0%E3%81%AE%E3%82%B5%E3%83%BC%E3%83%90%E3%81%8A%E3%81%A1%E3%81%A6%E3%82%8B%3C%2FSay%3E%0A%3C%2FResponse%3E&",
      method="GET",
      fallback_method="GET",
      status_callback_method="GET",
      record="false"
    )

    print(call.sid)


def get_staff():

    STAFF = yaml.load(open(os.path.join(current_dir,'staff.yml')).read().decode('utf-8'))

    AM00 = datetime.combine(date.today(), time(00,00))
    AM08 = datetime.combine(date.today(), time(8,00))
    PM17 = datetime.combine(date.today(), time(17,00))
    PM23 = datetime.combine(date.today(), time(23,00))

    now = datetime.now()
    weekday = datetime.now().weekday()

    if weekday == 0: #Monday
        if AM00 <= now < AM08: return STAFF['AMRY']
        elif AM08 <= now < PM17: return STAFF['CHEN']
        elif PM17 <= now < PM23: return STAFF['TANIMOTO']
        elif PM23 <= now: return STAFF['SEZAKI']

    elif weekday == 1: #Thuesday
        if AM00 <= now < AM08: return STAFF['SEZAKI']
        elif AM08 <= now < PM17: return STAFF['CHEN']
        elif PM17 <= now < PM23: return STAFF['TANIMOTO']
        elif PM23 <= now: return STAFF['SEZAKI']

    elif weekday == 2: #Wednesday
        if AM00 <= now < AM08: return STAFF['SEZAKI']
        elif AM08 <= now < PM17: return STAFF['CHEN']
        elif PM17 <= now < PM23: return STAFF['TANIMOTO']
        elif PM23 <= now: return STAFF['SEZAKI']

    elif weekday == 3: #Thursday
        if AM00 <= now < AM08: return STAFF['SEZAKI']
        elif AM08 <= now < PM17: return STAFF['CHEN']
        elif PM17 <= now < PM23: return STAFF['TANIMOTO']
        elif PM23 <= now: return STAFF['SEZAKI']

    elif weekday == 4: #Friday
        if AM00 <= now < AM08: return STAFF['SEZAKI']
        elif AM08 <= now < PM17: return STAFF['CHEN']
        elif PM17 <= now < PM23: return STAFF['TANIMOTO']
        elif PM23 <= now: return STAFF['SEZAKI']

    elif weekday == 5: #Saturday
        if AM00 <= now < AM08: return STAFF['SEZAKI']
        elif AM08 <= now < PM17: return STAFF['CHEN']
        elif PM17 <= now < PM23: return STAFF['SEZAKI']
        elif PM23 <= now: return STAFF['SEZAKI']

    elif weekday == 6: #Sunday
        if AM00 <= now < AM08: return STAFF['SEZAKI']
        elif AM08 <= now < PM17: return STAFF['SEZAKI']
        elif PM17 <= now < PM23: return STAFF['SEZAKI']
        elif PM23 <= now: return STAFF['SEZAKI']


if __name__ == '__main__':
    call(get_staff()['phone'])
    gmail = GMail('zabbix@adid.sg','onigiri/0517')
    msg = Message('Zabbix Called',to='sezaki@adid.sg',text=str(get_staff()))
    gmail.send(msg)


