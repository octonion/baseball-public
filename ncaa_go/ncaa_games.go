package main

import (
	"bytes"
	"encoding/csv"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	"regexp"
//	"runtime"
	"strings"
	"sync"
	"time"
	"github.com/moovweb/gokogiri"
)

const base_url = "http://web1.ncaa.org/stats/exec/records"
const records_xpath = "/html/body/table/tr[3]/td/form/table[2]/tr[position()>1]"

const retries = 7
const base_sleep = 200*time.Millisecond
const sleep_increment = 200*time.Millisecond

func process(team_id string, team_name string, year string, games *csv.Writer) {

	cookieJar, _ := cookiejar.New(nil)

	client := &http.Client{
		Jar: cookieJar,
	}

	values := url.Values{}
	values.Set("academicYear", year)
	values.Set("sportCode", "MFB")
	values.Set("orgId", team_id)

	ncaa_url := base_url+"?academicYear="+year+"&orgId="+team_id+"&sportCode=MFB"

	be := bytes.NewBufferString(values.Encode())

	req, err := http.NewRequest("POST", ncaa_url, be)

	req.Header.Set("User-Agent", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/34.0.1847.116 Chrome/34.0.1847.116 Safari/537.")
	var body []byte

	current_sleep := base_sleep

	i := 0
	for i < retries {
		resp, err := client.Do(req)
		if err != nil {
			fmt.Println(err)
			time.Sleep(time.Millisecond*current_sleep)
			i++
			current_sleep += sleep_increment
			continue
			//log.Fatalln(err)
		} else {
			defer resp.Body.Close()
			body, err = ioutil.ReadAll(resp.Body)
			if (err != nil) {
				fmt.Println(err)
				time.Sleep(time.Millisecond*current_sleep)
				i++
				current_sleep += sleep_increment
				continue
			} else {
				break
			}
		}
		return
	}

	doc, err := gokogiri.ParseHtml(body)
	if err != nil {
		fmt.Println(err)
	}
	defer doc.Free()

	nodes, err := doc.Search(records_xpath)
	if err != nil {
		fmt.Println(err)
	}

	for n := range nodes {
		var record []string
		record = append(record, year)
		record = append(record, team_name)
		record = append(record, team_id)
		subnodes, _ := nodes[n].Search("td")
		for s := range subnodes {

			text := strings.TrimSpace(subnodes[s].Content())
			record = append(record, text)

			if (s==0) {
				as, _ := subnodes[s].Search("a")
				if (len(as)>0) {
					href := as[0].Attribute("href").Value()
					re := regexp.MustCompile("[0-9]+")
					t_id := re.FindString(href)
					record = append(record, t_id)
				} else {
					record = append(record, "")
				}

			}

		}
		games.Write(record)
	}
}

func main() {

//	runtime.GOMAXPROCS(4)

	var wg sync.WaitGroup

	year := "2014"

	games_header := []string{"year", "team_name", "team_id", "opponent_name", "opponent_id", "game_date", "team_score", "opponent_score", "location", "neutral_site_location", "game_length", "attendance"}

	file_name := "csv/ncaa_games_go_"+year+".csv"
	f, err := os.Create(file_name)
	if err != nil {
		fmt.Println(err)
	}
	
	games := csv.NewWriter(f)
	games.Comma = '\t'
	games.Write(games_header)

	csvFile, err := os.Open("csv/ncaa_teams_"+year+".csv")
	defer csvFile.Close()
	if err != nil {
		panic(err)
	}
	csvReader := csv.NewReader(csvFile)
	csvReader.Comma = '\t'
	csvReader.TrailingComma = true
	i := 0
	for {
		fields, err := csvReader.Read()

		if (i==0) {
			i++
			continue
		}
		i++

		if err == io.EOF {
			break
		} else if err != nil {
			panic(err)
		}

		team_id := fields[1]
		team_name := fields[2]

		fmt.Println(fields)
		wg.Add(1)

		time.Sleep(time.Millisecond*200)
		
		go func() {
			defer wg.Done()
			process(team_id, team_name, year, games)
		}()

	}
	wg.Wait()
	games.Flush()
}
