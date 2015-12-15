import sys
import traceback
from flask import Flask, request
import requests

app = Flask(__name__)

def safeget(d, keys, default=None):
	for key in keys:
		try:
			d = d[key]
		except KeyError:
			return default
		except TypeError:
			return default
	return d

@app.route("/", methods=['GET'])
def index(*args, **kwargs):
	try:
		apiKey = request.args.get('apiKey', '')
		lat = request.args.get('lat', '40.71')
		lon = request.args.get('lon', '-74')
		units = request.args.get('units', 'us')
		lang = request.args.get('lang', 'en')

		r = requests.get('https://api.forecast.io/forecast/{apiKey}/{lat},{lon}?units={units}&lang={lang}'.format(**locals()))
		weather = r.json()

		current_temp = safeget(weather, ['currently', 'temperature'], 0)
		current_humidity = safeget(weather, ['currently', 'humidity'], 0)
		current_icon = safeget(weather, ['minutely', 'icon'], '')
		current_summary = safeget(weather, ['minutely', 'summary'], '')

		today = {}
		tomorrow = {}
		daily = safeget(weather, ['daily', 'data'])
		if len(daily) > 0:
			today = daily[0]
		if len(daily) > 1:
			tomorrow = daily[1]

		today_max_temp = safeget(today, ['temperatureMax'], 0)
		today_min_temp = safeget(today, ['temperatureMin'], 0)
		today_icon = safeget(today, ['icon'], '')
		today_summary = safeget(today, ['summary'], '')

		tomorrow_max_temp = safeget(tomorrow, ['temperatureMax'], 0)
		tomorrow_min_temp = safeget(tomorrow, ['temperatureMin'], 0)
		tomorrow_icon = safeget(tomorrow, ['icon'], '')
		tomorrow_summary = safeget(tomorrow, ['summary'], '')

		body = ("CURRENT_TEMP={current_temp}\n" +
			"CURRENT_HUMIDITY={current_humidity}\n" +
			"CURRENT_ICON={current_icon}\n" +
			"CURRENT_SUMMARY={current_summary}\n" +
			"MAX_TEMP_TODAY={today_max_temp}\n" +
			"MIN_TEMP_TODAY={today_min_temp}\n" +
			"ICON_TODAY={today_icon}\n" +
			"SUMMARY_TODAY={today_summary}\n" +
			"MAX_TEMP_TOMORROW={tomorrow_max_temp}\n" +
			"ICON_TOMORROW={tomorrow_icon}\n" +
			"MIN_TEMP_TOMORROW={tomorrow_min_temp}\n" +
			"SUMMARY_TOMORROW={tomorrow_summary}\n"
			).format(**locals())

		print body
		return body
	except:
		traceback.print_exc()
		return "Uh, unexpected error"

if __name__ == "__main__":
	app.run(host='0.0.0.0')
