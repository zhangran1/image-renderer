import argparse
from google.cloud import pubsub_v1

def create_pubsub_topic(project_id: str, topic_id: str):
    """Creates a new Pub/Sub topic."""
    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(project_id, topic_id)

    try:
        topic = publisher.create_topic(request={"name": topic_path})
        print(f"Topic {topic.name} created.")
    except Exception as e:
        print(f"Error creating topic {topic_id}: {e}")
        print(f"Topic {topic_id} might already exist or you don't have permissions.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Create a Google Cloud Pub/Sub topic."
    )
    parser.add_argument(
        "--project_id",
        required=True,
        help="Your Google Cloud project ID.",
    )
    parser.add_argument(
        "--topic_id",
        required=True,
        help="The ID of the Pub/Sub topic to create.",
    )
    args = parser.parse_args()

    create_pubsub_topic(args.project_id, args.topic_id)
