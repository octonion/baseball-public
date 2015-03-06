#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent = 'Mozilla/5.0'

url = "http://www.koreabaseball.com/Record/Player/HitterDetail/Game.aspx?playerId=76325"

page = agent.get(url)

form = page.forms[0]

p form['ctl00$ctl00$cphContainer$cphContents$ddlYear']

form['ctl00$ctl00$cphContainer$cphContents$ddlYear'] = 2013

page = form.submit

form = page.forms[0]

p form['ctl00$ctl00$cphContainer$cphContents$ddlYear']
