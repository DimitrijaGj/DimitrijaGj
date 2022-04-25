#!/usr/bin/env python

from urllib import response
from APIkey import headers
import requests
import json
from pprint import pprint

payload = {}

headers = headers

# ------------ Input assettag-----------
print("Please enter assetag:")

input_tag = input()
print("Assettag is:")
print(input_tag)

# --------------------------------------
# URL to location on request
# One way to add variable to URI
url = "https://it-inventory.trvapps.com/api/v1/hardware/bytag/{}".format(input_tag)

# Other way
# url = f"https://it-inventory.trvapps.com/api/v1/hardware/bytag/" + input_tag

response = requests.request("GET", url, headers=headers, data=payload)

# Converting answer into JSON format
hardware = response.json()
# hardware = json.loads(response.text)

"""
# recovert in JSON file
# pprint(json.dumps(hardware))
# pprint(hardware)
"""

# to print out only serial
# end= makes two ot more lines to be prointed one after another
# "def" is function that exe all what is in the function


def print_serial_name():

    serial = hardware["serial"]

    assigned_to = hardware["assigned_to"]["name"]

    print(
        "Serial number of the asset is:\n"
        + serial
        + "\n and is assigned to:\n"
        + assigned_to
    )


print_serial_name()


#### VERY IMPORTANT-------------------------------------------------------------
"""
# "for" only for arrays100008723
for user in hardware["serial"]
    # use for dictionaries
    # searching in the dictionary
    user["id"]
    name = user["id"]

    print(name)
###VERY IMPORTANT----------------------------------------------------------------
"""
