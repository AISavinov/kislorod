import requests
import json
import datetime

print(datetime.datetime.now())
params = {
  "from": '1550347200',
  "to": "1561650764",
  "date_type": "cleaning_date"
}
r = requests.get("http://kislorodlab.sys.it-co.ru/api/get_orders?token=db3d7e90af505b851146f0c84891e737", data=params)
print(r.json())

#with open("resp.json", 'w') as f:
#	json.dump([r.json()], f)