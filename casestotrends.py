import pandas as pd
import datetime

cases = pd.read_stata("processed/all_cases_states.dta")

weekbystate = pd.read_stata("clean/trends.dta")
daily = pd.read_stata("clean/daily_trends.dta")

#print(daily)
#print(cases)

numleads = 7
numlags = 7



for i in range(numleads):
    daily['lead'+str(i + 1)] = 0
    weekbystate['lead'+str(i + 1)] = 0

for i in range(numlags):
    daily['lag'+str(i + 1)] = 0
    weekbystate['lag'+str(i + 1)] = 0

daily['casedate'] = 0
weekbystate['casedate'] = 0

"""
# Daily
for date in cases['date_op']:
    #
    daily.loc[daily['date']==date,'casedate'] = 1
    for i in range(numleads):
        dn = date - pd.DateOffset(days= (i + 1))
        daily.loc[daily['date']==dn,'lead' + str(i + 1)] = 1


    for i in range(numlags):
        dn = date + pd.DateOffset(days= (i + 1))
        daily.loc[daily['date']==dn,'lag' + str(i + 1)] = 1

daily.to_stata('processed/daily_trends_cases_lags.dta')
"""
for index, row in cases.iterrows():
    #
    date = row['weekof']
    state = row['state']

    weekbystate.loc[(weekbystate['date']==date) & (weekbystate['state']==state),'casedate'] = 1
    for i in range(numleads):
        dn = date - pd.DateOffset(weeks= (i + 1))
        weekbystate.loc[(weekbystate['date']==dn) & (weekbystate['state']==state),'lead' + str(i + 1)] = 1


    for i in range(numlags):
        dn = date + pd.DateOffset(weeks= (i + 1))
        weekbystate.loc[(weekbystate['date']==dn) & (weekbystate['state']==state),'lag' + str(i + 1)] = 1

weekbystate.to_stata('processed/states_trends_cases_lags.dta')
