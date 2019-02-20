import pandas as pd
import datetime

cases = pd.read_stata("processed/all_cases_states.dta")

cases = cases.sort_values(by=['id6s','date_op'])

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


# Daily
def daily():
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

def weekstate():
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

def schools():
    schools = daily = pd.read_stata("processed/school_full_cases.dta")

    numleads = 5
    numlags = 5

    for i in range(numleads):
        schools['lead'+str(i + 1)] = 0

    for i in range(numlags):
        schools['lag'+str(i + 1)] = 0

    schools['casedate'] = 0

    for index, row in cases.iterrows():
        #
        year = (row['weekof'] - pd.DateOffset(months = 6)).year
        id = row['id6s']

        schools.loc[(schools['year']==year) & (schools['id6s']==id),'casedate'] = 1
        for i in range(numleads):
            yn = year - (i + 1)
            schools.loc[(schools['year']==yn) & (schools['id6s']==id),'lead' + str(i + 1)] = 1


        for i in range(numlags):
            yn = year + (i + 1)
            schools.loc[(schools['year']==yn) & (schools['id6s']==id),'lag' + str(i + 1)] = 1

    schools.to_stata('processed/schools_cases_lags.dta')

def schoolsnew():
    schools = daily = pd.read_stata("processed/school_full_cases.dta")

    numleads = 2
    numlags = 3
    for j in range(7):
        for i in range(numleads):
            schools['lead'+str(i + 1)+str(j)] = 0

        for i in range(numlags):
            schools['lag'+str(i + 1)+str(j)] = 0

        schools['casedate'+str(j)] = 0

    count = 0
    last_id = ""

    for index, row in cases.iterrows():
        #

        year = (row['weekof'] - pd.DateOffset(months = 6)).year
        id = row['id6s']

        if id != last_id:
            count = 0
        else:
            count += 1

        schools.loc[(schools['year']==year) & (schools['id6s']==id),'casedate' + str(count)] = 1
        for i in range(numleads):
            yn = year - (i + 1)
            schools.loc[(schools['year']==yn) & (schools['id6s']==id),'lead' + str(i + 1) + str(count)] = 1


        for i in range(numlags):
            yn = year + (i + 1)
            schools.loc[(schools['year']==yn) & (schools['id6s']==id),'lag' + str(i + 1) + str(count)] = 1

        last_id = id

    schools.to_stata('processed/schools_cases_lags_new.dta')

# daily()
# weekbystate()
schools()
#schoolsnew()
