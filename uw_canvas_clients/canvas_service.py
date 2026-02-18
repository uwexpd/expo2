from flask import Flask, jsonify
from uw_canvas.enrollments import Enrollments

app = Flask(__name__)
enrollments_client = Enrollments()

@app.route('/course/<int:course_id>/roster', methods=['GET'])
def get_course_roster(course_id):
    try:
        enrollments = enrollments_client.get_enrollments_for_course(course_id)
        roster = []
        for enrollment in enrollments:
            roster.append({
                'user_id': enrollment.user_id,
                'name': enrollment.name,
                'role': enrollment.role,
                'status': enrollment.status,
                'course_id': enrollment.course_id,
                'course_name': enrollment.course_name,
                'section_id': enrollment.section_id,
                'sortable_name': enrollment.sortable_name,
            })
        return jsonify(roster)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(port=5000)