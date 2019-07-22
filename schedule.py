import requests
import json
import datetime
import pprint

curr_t = int(datetime.datetime.now().timestamp())
curr_t_m_d = int((datetime.datetime.now() - datetime.timedelta(days=15, hours=24)).timestamp())

print(curr_t)
print(curr_t_m_d)

params = {
  "from": "{}".format(str(curr_t_m_d)),
  "to": "{}".format(str(curr_t)),
  "date_type": "cleaning_date"
}
print(params)
r = requests.get("http://kislorodlab.sys.it-co.ru/api/get_orders?token=db3d7e90af505b851146f0c84891e737", data=params)
pprint.pprint(r.json())
for lead in r.json()['data'][0]['leads']:
  print()
  print(lead)
  print(lead['customer']['roistat_first_visit'])
  print(lead['customer']['ga_cid'])
  print(lead['customer']['ym_id'])
#with open("resp.json", 'w') as f:
#	json.dump([r.json()], f)