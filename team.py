import http.client
import json

connection = http.client.HTTPConnection('api.football-data.org')
headers = { 'X-Auth-Token': '56a2a2ce412f41ebbbc076c0b025538b', 'X-Response-Control': 'minified' }
connection.request('GET', '/v1/teams/64/fixtures', None, headers )


raw_data = json.loads(connection.getresponse().read().decode())
	
fixtures = raw_data['fixtures']


# get actual round
def get_actual_round():
	for round in range(len(fixtures)):
		if('TIMED' in fixtures[round].values()):
			return round

def get_next_match():
	return fixtures[get_actual_round()]

def is_home():
	if(get_next_match()['homeTeamId'] == 64):
		return True
	elif(get_next_match()['awayTeamId'] == 64):
		return False
	else:
		print("Not a LFC match")


def get_next_opponent_name():
	if(is_home()):
		return get_next_match()['awayTeamName']
	else:
		return get_next_match()['homeTeamName']

def get_next_opponent_id():
	if(is_home()):
		return get_next_match()['awayTeamId']
	else:
		return get_next_match()['homeTeamId']