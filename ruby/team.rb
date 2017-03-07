require 'net/http'
require 'uri'
require 'json'
require 'ostruct'

def define_club
	# Liverpool id is 64
	return club_id = 64
end

def connect_to_api
	club_id = define_club

	url = URI.parse("http://api.football-data.org/v1/teams/" + club_id.to_s + "/fixtures")
	req = Net::HTTP::Get.new(url.path)
	req.add_field("X-Auth-Token", "56a2a2ce412f41ebbbc076c0b025538b")
	res = Net::HTTP.new(url.host, url.port).start do |http|
		http.request(req)
	end
	return res.body
end

def get_team_fixtures
	raw_data = JSON.parse(connect_to_api())
	fixtures = raw_data['fixtures']
	return fixtures
end

def get_actual_round
	fixtures = get_team_fixtures()
	for x in 0..fixtures.length-1
	  if fixtures[x]["status"] == ("TIMED" or "LIVE") 
	    return x 
	  end  
	end
end

def get_next_match
	fixtures = get_team_fixtures()
	actual_round = get_actual_round()
	return OpenStruct.new(fixtures[actual_round])
end

def is_home
	club_name = "Liverpool FC"
	next_match = get_next_match()
	if next_match.homeTeamName == club_name
		return true
	elsif next_match.awayTeamName == club_name
		return false
	end
end

def get_next_opponent_id
	next_match = get_next_match()
	if is_home()
		team_status = "awayTeam"
	else
		team_status = "homeTeam"
	end
		opponent_link = next_match._links[team_status]["href"]

	l = ""
	opponent_link.reverse.each_char do |i|
		if i != "/"
			l.insert(0,i)
		else
			break
		end
	end

	return l.to_i
end