require 'net/http'
require 'uri'
require 'json'
require 'ostruct'
require 'date'

def default_club()
	# Liverpool id is 64
	return club_id = 64
end

def connect_to_api(url_complement)
	url = URI.parse("http://api.football-data.org" + url_complement)
	req = Net::HTTP::Get.new(url.path)
	req.add_field("X-Auth-Token", "56a2a2ce412f41ebbbc076c0b025538b")
	res = Net::HTTP.new(url.host, url.port).start do |http|
		http.request(req)
	end
	return res.body
end

def get_team_fixtures()
	url_complement = "/v1/teams/" + default_club.to_s + "/fixtures"
	raw_data = JSON.parse(connect_to_api(url_complement))
	fixtures = raw_data['fixtures']
	return fixtures
end

def get_actual_round()
	fixtures = get_team_fixtures()
	for x in 0..fixtures.length-1
	  if fixtures[x]["status"] == ("TIMED" or "LIVE") 
	    return x 
	  end  
	end
end

def get_next_match()
	fixtures = get_team_fixtures()
	actual_round = get_actual_round()
	return OpenStruct.new(fixtures[actual_round])
end

def is_home()
	club_name = "Liverpool FC"
	next_match = get_next_match()
	if next_match.homeTeamName == club_name
		return true
	elsif next_match.awayTeamName == club_name
		return false
	end
end

def get_next_opponent_id()
	if is_home()
		team_status = "awayTeam"
	else
		team_status = "homeTeam"
	end

	next_match = get_next_match()
	opponent_link = next_match._links[team_status]["href"]

	id_string = ""
	opponent_link.reverse.each_char do |i|
		if i != "/"
			id_string.insert(0,i)
		else
			break
		end
	end

	return id_string.to_i
end

def create_team(team_id)
	url_complement = "/v1/teams/" + team_id.to_s
	team_raw = JSON.parse(connect_to_api(url_complement))
	team = OpenStruct.new(team_raw)
	return team
end

def create_default_team()
	return create_team(defaul_club)
end

def create_opponent()
	return create_team(get_next_opponent_id())
end

def get_next_match_date()
	match = get_next_match()
	return DateTime.parse(match.date).to_date
end

def does_default_team_play_today()
	if get_next_match_date == Date.today
		return true
	else
		return false
	end
end

def how_many_days_until_next_match()
	return get_next_match_date().mjd - Date.today.mjd
end

def when_will_default_team_play
	weekday_name = ["Domingo","Segunda","Terça","Quarta","Quinta","Sexta","Sábado"]
	wday_number = get_next_match_date().wday

	days = how_many_days_until_next_match

	case days
	when 0
		description = "Hoje"
	when 1
		description = "Amanhã"
	when 2..6	
		description = weekday_name[wday_number]
	when 7..14
		description = "Semana que vem"
	else "Daqui " + (days/7).to_s + " semanas"
	end


	return description
end