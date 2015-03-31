#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent = 'Mozilla/5.0'

url = "http://www.koreabaseball.com/Player/Register.aspx"

page = agent.get(url)

p page.forms

form = page.forms[0]

p form['ctl00$ctl00$cphContainer$cphContents$hfSearchTeam']
p form['ctl00$ctl00$cphContainer$cphContents$hfSearchDate']

form['ctl00$ctl00$cphContainer$cphContents$hfSearchTeam'] = 'WO'
form['ctl00$ctl00$cphContainer$cphContents$hfSearchDate'] = '2015-03-28'

page = form.submit

form = page.forms[0]

p form['ctl00$ctl00$cphContainer$cphContents$hfSearchTeam']
p form['ctl00$ctl00$cphContainer$cphContents$hfSearchDate']
