import http.client
import json
from datetime import datetime

club_id = 81

connection = http.client.HTTPConnection('api.football-data.org')
headers = { 'X-Auth-Token': '56a2a2ce412f41ebbbc076c0b025538b', 'X-Response-Control': 'minified' }

class objectview(object):
    def __init__(self, d):
        self.__dict__ = d

def get_team_fixtures():
	connection.request('GET', '/v1/teams/' + str(club_id) + '/fixtures', None, headers )
	raw_data = json.loads(connection.getresponse().read().decode())
	fixtures = raw_data['fixtures']
	return fixtures

def get_actual_round():
	fixtures = get_team_fixtures()
	for round in range(len(fixtures)):
		if(('TIMED' or 'LIVE') in fixtures[round].values()):
			return round

def get_next_match():
	fixtures = get_team_fixtures()
	actual_round = get_actual_round()
	return objectview(fixtures[actual_round])

def is_home():
	next_match = get_next_match()
	if(next_match.homeTeamId == club_id):
		return True
	elif(next_match.awayTeamId == club_id):
		return False

def get_next_opponent_id():
	next_match = get_next_match()
	if(is_home()):
		return next_match.awayTeamId
	else:
		return next_match.homeTeamId

def create_team(team_id):
	connection.request('GET', '/v1/teams/' + str(team_id), None, headers)
	team = objectview(json.loads(connection.getresponse().read().decode()))
	return team

def create_liverpool():
	return create_team(club_id)

def create_opponent():
	return create_team(get_next_opponent_id())

def get_match_date():
	match = get_next_match()
	from dateutil.parser import parse
	return parse(match.date)


def is_the_match_today():
	if(datetime.today().date() == get_match_date().date()):
		return True
	else:
		return False