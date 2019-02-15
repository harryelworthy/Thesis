import pprint
from googleapiclient.discovery import build
import pandas as pd

SERVER = 'https://www.googleapis.com'

API_VERSION = 'v1beta'
DISCOVERY_URL_SUFFIX = '/discovery/v1/apis/trends/' + API_VERSION + '/rest'
DISCOVERY_URL = SERVER + DISCOVERY_URL_SUFFIX

service = build('trends', 'v1beta',
                  developerKey='',
                  discoveryServiceUrl=DISCOVERY_URL)

s1 = '2008-01'
e1 = '2013-01'
s2 = '2013-01'
e2 = '2018-01'

weeks_in_jan = 4

statecodes = [
'AL',
'AK',
'AZ',
'AR',
'CA',
'CO',
'CT',
'DE',
'FL',
'GA',
'HI',
'ID',
'IL',
'IN',
'IA',
'KS',
'KY',
'LA',
'ME',
'MD',
'MA',
'MI',
'MN',
'MS',
'MO',
'MT',
'NE',
'NV',
'NH',
'NJ',
'NM',
'NY',
'NC',
'ND',
'OH',
'OK',
'OR',
'PA',
'RI',
'SC',
'SD',
'TN',
'TX',
'UT',
'VT',
'VA',
'WA',
'WV',
'WI',
'WY',
''
]

properties = ['', 'news']

terms = ['rape', 'sexual assault']

#for s in statecodes:
#    for p in properties:
#        for t in terms:
#            full_search(t,s,p)



df = pd.DataFrame(columns=['date','value','term','state','property'])

def full_search(term, state='', property=''):
    """
    Searches over whole time period, readjusts values, pastes dictionaries together
    """
    geo = ""
    if state == '':
        geo = state = 'US'
    else:
        geo = 'US-' + state

    response1 = service.getGraph(terms=term,
                              restrictions_startDate=s1,
                              restrictions_endDate=e1,
                              restrictions_geo=geo,
                              restrictions_property=property).execute().get('lines')[0].get('points')
    response2 = service.getGraph(terms=term,
                              restrictions_startDate=s2,
                              restrictions_endDate=e2,
                              restrictions_geo=geo,
                              restrictions_property=property).execute().get('lines')[0].get('points')

    multiplier = 1
    if response2[weeks_in_jan - 1].get('value') != 0:
        multiplier = response1[-1].get('value')/response2[weeks_in_jan - 1].get('value')

    for i in response2:
        i['value'] = i['value']*multiplier

    combined = response1 + response2[weeks_in_jan:]

    if property == '':
        property = 'web'

    df1 = pd.DataFrame(combined)

    df1['term'] = term
    df1['state'] = state
    df1['property'] = property

    return df1

df = full_search('apples')

for s in statecodes:
    for p in properties:
        for t in terms:
            df = df.append(full_search(t,s,p))
            print(t + ', ' + s + ', ' + p)

df.to_csv('raw/trends.csv')
