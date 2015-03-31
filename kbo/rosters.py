#!/usr/bin/env python

import mechanize

agent = mechanize.Browser()
agent.set_handle_robots(False)

url = "http://www.koreabaseball.com/Player/Register.aspx"

agent.open(url)

agent.select_form(nr=0)

agent.set_all_readonly(False)

print agent['ctl00$ctl00$cphContainer$cphContents$hfSearchTeam']
print agent['ctl00$ctl00$cphContainer$cphContents$hfSearchDate']

agent['ctl00$ctl00$cphContainer$cphContents$hfSearchTeam'] = 'WO'
agent['ctl00$ctl00$cphContainer$cphContents$hfSearchDate'] = '2015-03-28'

result = agent.submit()
content = result.read()

with open("mechanize_results.html", "w") as f:
    f.write(content)
