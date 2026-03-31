# Service account for Pub/Sub subscription pushing to Cloud Function
module "pubsub_invoker_sa" {
  source = "../../modules/cloud-fabric/iam-service-account"
  project_id = var.pubsub_invoker_sa_project_id
  name       = var.pubsub_invoker_sa_name

  iam_project_roles = {
    "${var.pubsub_invoker_sa_target_project_id}" = [
      "roles/cloudfunctions.invoker",
      "roles/run.invoker"
    ]
  }
}

# Pub/Sub Topic for Cloud Function Invocation
# This topic is used to trigger a Cloud Function via a push subscription.
module "pubsub_topic" {
  source = "../../modules/cloud-fabric/pubsub"

  project_id = var.pubsub_topic_project_id
  name       = var.pubsub_topic_name

  # HARDCODED POLICY: 7-day retention required for audit/replayability
  message_retention_duration = "604800s"

  subscriptions = var.pubsub_subscriptions

  labels = {
    env  = var.pubsub_topic_env
    team = var.pubsub_topic_team
  }

  depends_on = [
    module.pubsub_invoker_sa
  ]
}
