import argparse

from google.api_core import exceptions
from google.cloud import redis_v1


def create_instance(project_id: str, location_id: str, instance_id: str) -> None:
    """
    Create a new Memorystore for Redis instance with the lowest possible cost.

    Args:
        project_id (str): Google Cloud project ID.
        location_id (str): Google Cloud region.
        instance_id (str): New Memorystore for Redis instance ID.
    """
    client = redis_v1.CloudRedisClient()
    parent = f"projects/{project_id}/locations/{location_id}"

    # Configure the instance for the lowest cost (BASIC tier, 1GB memory)
    instance = redis_v1.Instance(
        tier="BASIC",
        memory_size_gb=1,
    )

    try:
        operation = client.create_instance(
            request={"parent": parent, "instance_id": instance_id, "instance": instance}
        )
        print(f"Creating instance '{instance_id}' in '{location_id}'. This may take a few minutes...")
        
        # Wait for the operation to complete
        response = operation.result()
        
        print(f"Instance created successfully: {response.name}")
        print(f"  Tier: {response.tier.name}")
        print(f"  Memory: {response.memory_size_gb} GB")
        print(f"  Host: {response.host}")
        print(f"  Port: {response.port}")


    except exceptions.AlreadyExists:
        print(f"Instance '{instance_id}' already exists in '{location_id}'.")
    except exceptions.GoogleAPICallError as e:
        print(f"An API error occurred while creating the instance: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Create a new low-cost Memorystore for Redis instance.",
    )
    parser.add_argument(
        "--project_id",
        type=str,
        required=True,
        help="Your Google Cloud project ID.",
    )
    parser.add_argument(
        "--location_id",
        type=str,
        required=True,
        help="The Google Cloud region for the instance (e.g., 'us-central1').",
    )
    parser.add_argument(
        "--instance_id",
        type=str,
        required=True,
        help="The ID for the new Memorystore for Redis instance.",
    )
    args = parser.parse_args()

    create_instance(args.project_id, args.location_id, args.instance_id)
