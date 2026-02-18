import os
import requests

course_id = 1878551
token = os.getenv('RESTCLIENTS_CANVAS_OAUTH_BEARER')
host = os.getenv('RESTCLIENTS_CANVAS_HOST')

url = f"{host}/api/v1/courses/{course_id}/enrollments"
headers = {
    'Authorization': f'Bearer {token}'
}

response = requests.get(url, headers=headers)
print(f"Status code: {response.status_code}")
print(response.text)


