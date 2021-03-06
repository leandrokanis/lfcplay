import http.client
import json

liverpool_id = 99

connection = http.client.HTTPConnection('api.football-data.org')
headers = { 'X-Auth-Token': '56a2a2ce412f41ebbbc076c0b025538b', 'X-Response-Control': 'minified' }
connection.request('GET', '/v1/teams/' + str(liverpool_id) + '/fixtures', None, headers )

raw_data = json.loads(connection.getresponse().read().decode())
	
fixtures = raw_data['fixtures']

class objectview(object):
    def __init__(self, d):
        self.__dict__ = d

# get actual round
def get_actual_round():
	for round in range(len(fixtures)):
		if(('TIMED' or 'LIVE') in fixtures[round].values()):
			return round

def get_next_match():
	actual_round = get_actual_round()
	return objectview(fixtures[actual_round])

def is_home():
	next_match = get_next_match()
	if(next_match.homeTeamId == liverpool_id):
		return True
	elif(next_match.homeTeamId == liverpool_id):
		return False
	else:
		print("Not a LFC match")

def get_next_opponent_id():
	next_match = get_next_match()
	if(is_home()):
		return next_match.awayTeamId
	else:
		return next_match.homeTeamId

def create_team(team_id):
	connection.request('GET', '/v1/teams/'+str(team_id), None, headers)
	team = objectview(json.loads(connection.getresponse().read().decode()))
	return team

def create_liverpool():
	return create_team(liverpool_id)

def create_opponent():
	return create_team(get_next_opponent_id())