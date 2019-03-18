#!/usr/bin/env python

import requests
import json
import sys

urlSearchString = str(sys.argv[1])
bearerToken = 'basic ' + str(sys.argv[2])

print('Customer Search:', urlSearchString)

headers = {
  'Authorization': bearerToken
}

# Create the search URL
url = 'https://t3n.zendesk.com/api/v2/search.json?query=' + urlSearchString + ' status<closed&sort_by=date&sort_order=desc'
response = requests.get(url,headers=headers,verify=True)
#print (response.status_code)
# For successful API call, response code will be 200 (OK)
if(response.ok):
  # Loading the response data into a dict variable
  casecount = response.json()['count']
  print('Case Count:',(casecount))
  #response.json()['results']  
  # For each resault parse the ticket info
  for result in list(response.json()['results']):
    ticketID = (result['id'])
    ticketSubject = (result['subject'])
    ticketStatus = (result['status'])
    ticketURL = (result['url'])
    print((ticketID),"-",(ticketSubject),'- Status: ' + str(ticketStatus))
    hyperlink = "<a href='https://t3n.zendesk.com/agent/tickets/" + str(ticketID) + "'>ticketID</a>"
    pass
else:
  # If response code is not ok (200), print the resulting http error code with description
  response.raise_for_status()
  pass





