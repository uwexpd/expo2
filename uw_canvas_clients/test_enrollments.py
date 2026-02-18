import logging
import os
from uw_canvas.enrollments import Enrollments

# Enable debug logging for detailed HTTP request/response info
logging.basicConfig(level=logging.DEBUG)

def main():
    # Print environment variables to verify configuration
    print("Canvas Host:", os.getenv("RESTCLIENTS_CANVAS_HOST"))
    token = os.getenv("RESTCLIENTS_CANVAS_OAUTH_BEARER")
    print("Canvas Token (partial):", token[:4] + "..." if token else "None")

    course_id = 1878551  # Replace with your actual course ID

    enrollments_client = Enrollments()
    print("Enrollments():", enrollments_client)
    try:
        print(f"Requesting enrollments for course ID: {course_id}")
        enrollments = enrollments_client.get_enrollments_for_course(course_id)

        print(f"Found {len(enrollments)} enrollments")
        for enrollment in enrollments:
            print(f"User ID: {enrollment.user_id}, Name: {enrollment.name}, Role: {enrollment.role}, Status: {enrollment.status}")
    except Exception as e:
        print(f"Error fetching enrollments: {e}")

if __name__ == "__main__":
    main()