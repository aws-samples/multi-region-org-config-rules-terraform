variable "region" {
    type = string
}

##########
# S3 Variables
##########
variable "encryption_enabled" {
  type        = bool
  default     = false
  description = "When set to 'true' the resource will have aes256 encryption enabled by default"
}
variable "config_bucket" {
    description = "Name for the S3 Bucket for AWS Config if using new S3 Bucket"
}

###########################################
##### S3 Logging Policy Variables

# Perm Check Section
variable "s3-permcheck-logging-sid" {
  description = "Name of SID"
  default = "AWSBucketPermissionsCheck"
}

variable "s3-permcheck-logging-effect" {
  default = "Allow"
}

variable "s3-permcheck-logging-actions" {
  type        = list
  description = "List of IAM actions to include in policy"
  default     = ["s3:GetBucketAcl",]
}

# Perm Delivery Section
variable "s3-delivery-logging-sid" {
  description = "Name of SID"
  default = "AWSBucketDelivery"
}

variable "s3-deliver-logging-effect" {
  default = "Allow"
}

variable "s3-delivery-logging-actions" {
  type        = list
  description = "List of IAM actions to include in policy"
  default     = ["s3:PutObject",]
}

# Consistent Principal Variables
variable "s3-logging-principal-type" {
  type        = string
  default     = "Service"
}

variable "s3-logging-identifier" {
  type        = list
  default     = ["config.amazonaws.com",]
}



##################
# Config Variables
#################
# Used as an parameters value for Manage Config Rules, specifically to enforce IAM Password Policy
# where the values are fed in as a mapped string.
variable "input_parameters" {
  description = "A map of strings in JSON format."
  type = map(string)
  default = {
    iam-password-policy = <<EOF
    { 
      "RequireUppercaseCharacters": "true",
      "RequireLowercaseCharacters": "true",
      "RequireSymbols": "true",
      "RequireNumbers": "true",
      "MinimumPasswordLength": "9",
      "PasswordReusePrevention": "5",
      "MaxPasswordAge": "90"
    }
      EOF
  }
}

# Security Account Number for when Config Rules aggregates its logs to destination
variable "security_account_number"{
  type = string
  description = "12-digit Security Account number for AWS Config Aggregation authorization."
}

# A map of config rules that will be active and selected from list
variable "rules" {
  default     = [
    "cloudtrail-enabled",
    "restricted-ssh",
    "root-account-mfa-enabled",
    "s3-bucket-logging-enabled",
    "s3-bucket-public-read-prohibited",
    "s3-bucket-public-write-prohibited",
    "s3-bucket-ssl-requests-only",
    "s3-bucket-server-side-encryption-enabled",
    "rds-storage-encrypted",
    "encrypted-volumes",
    "iam-password-policy"
  ]
  description = "The list of rules to enable in AWS Config. Used with source_identifiers mapping for AWS Config Managed Rules."
  type        = list
}

variable "source_identifiers" {
  default     = {
    access-keys-rotated                                     = "ACCESS_KEYS_ROTATED"
    acm-certificate-expiration-check                        = "ACM_CERTIFICATE_EXPIRATION_CHECK"
    alb-http-to-https-redirection-check                     = "ALB_HTTP_TO_HTTPS_REDIRECTION_CHECK"
    api-gw-execution-logging-enabled                        = "API_GW_EXECUTION_LOGGING_ENABLED"
    api-gw-cache-enabled-and-encrypted                      = "API_GW_CACHE_ENABLED_AND_ENCRYPTED"
    api-gw-endpoint-type-check                              = "API_GW_ENDPOINT_TYPE_CHECK"
    aproved-amis-by-id                                      = "APPROVED_AMIS_BY_ID"
    approved-amis-by-tag                                    = "APPROVED_AMIS_BY_TAG"
    autoscaling-group-elb-healthcheck-required              = "AUTOSCALING_GROUP_ELB_HEALTHCHECK_REQUIRED"
    cloudformation-stack-drift-detection-check              = "CLOUDFORMATION_STACK_DRIFT_DETECTION_CHECK"
    cloudformation-stack-notification-check                 = "CLOUDFORMATION_STACK_NOTIFICATION_CHECK"
    cloudfront-viewer-policy-https                          = "CLOUDFRONT_VIEWER_POLICY_HTTPS"
    cloud-trail-cloud-watch-logs-enabled                    = "CLOUD_TRAIL_CLOUD_WATCH_LOGS_ENABLED"
    cloudtrail-enabled                                      = "CLOUD_TRAIL_ENABLED"
    cloud-trail-encryption-enabled                          = "CLOUD_TRAIL_ENCRYPTION_ENABLED"
    cloud-trail-log-file-validation-enabled                 = "CLOUD_TRAIL_LOG_FILE_VALIDATION_ENABLED"
    cloudwatch-alarm-action-check                           = "CLOUDWATCH_ALARM_ACTION_CHECK"
    cloudwatch-alarm-resource-check                         = "CLOUDWATCH_ALARM_RESOURCE_CHECK"
    cloudwatch-alarm-settings-check                         = "CLOUDWATCH_ALARM_SETTINGS_CHECK"
    cloudwatch-log-group-encrypted                          = "CLOUDWATCH_LOG_GROUP_ENCRYPTED"
    cmk-backing-key-rotation-enabled                        = "CMK_BACKING_KEY_ROTATION_ENABLED"
    codebuild-project-envvar-awscred-check                  = "CODEBUILD_PROJECT_ENVVAR_AWSCRED_CHECK"
    codebuild-project-source-repo-url-check                 = "CODEBUILD_PROJECT_SOURCE_REPO_URL_CHECK"
    codepipeline-deployment-count-check                     = "CODEPIPELINE_DEPLOYMENT_COUNT_CHECK"
    codepipeline-region-fanout-check                        = "CODEPIPELINE_REGION_FANOUT_CHECK"
    db-instance-backup-enabled                              = "DB_INSTANCE_BACKUP_ENABLED"
    desired-instance-tenancy                                = "DESIRED_INSTANCE_TENANCY"
    desired-instance-type                                   = "DESIRED_INSTANCE_TYPE"
    dms-replication-not-public                              = "DMS_REPLICATION_NOT_PUBLIC"
    dynamodb-autoscaling-enabled                            = "DYNAMODB_AUTOSCALING_ENABLED"
    dynamodb-throughput-limit-check                         = "DYNAMODB_THROUGHPUT_LIMIT_CHECK"
    dynamodb-encryption-encryption-enabled                  = "DYNAMODB_TABLE_ENCRYPTION_ENABLED"
    dynamodb-table-encryption-enabled                       = "DYNAMODB_TABLE_ENCRYPTION_ENABLED"
    ebs-optimized-instance                                  = "EBS_OPTIMIZED_INSTANCE"
    ebs-snapshot-public-restorable-check                    = "EBS_SNAPSHOT_PUBLIC_RESTORABLE_CHECK"
    ec2-instance-detailed-monitoring-enabled                = "EC2_INSTANCE_DETAILED_MONITORING_ENABLED"
    ec2-instances-in-vpc                                    = "INSTANCES_IN_VPC"
    ec2-instance-managed-by-systems-manager                 = "EC2_INSTANCE_MANAGED_BY_SSM"
    ec2-instance-no-public-ip                               = "EC2_INSTANCE_NO_PUBLIC_IP"
    ec2-managedinstance-applications-blacklisted            = "EC2_MANAGEDINSTANCE_APPLICATIONS_BLACKLISTED"
    ec2-managedinstance-applications-required               = "EC2_MANAGEDINSTANCE_APPLICATIONS_REQUIRED"
    ec2-managedinstance-association-compliance-status-check = "EC2_MANAGEDINSTANCE_ASSOCIATION_COMPLIANCE_STATUS_CHECK"
    ec2-managedinstance-inventory-blacklisted               = "EC2_MANAGEDINSTANCE_INVENTORY_BLACKLISTED"
    ec2-managedinstance-patch-compliance-status-check       = "EC2_MANAGEDINSTANCE_PATCH_COMPLIANCE_STATUS_CHECK"
    ec2-managedinstance-platform-check                      = "EC2_MANAGEDINSTANCE_PLATFORM_CHECK"
    ec2-security-group-attached-to-eni                      = "EC2_SECURITY_GROUP_ATTACHED_TO_ENI"
    ec2-stopped-instance                                    = "EC2_STOPPED_INSTANCE"
    ec2-volume-inuse-check                                  = "EC2_VOLUME_INUSE_CHECK"
    efs-encrypted-check                                     = "EFS_ENCRYPTED_CHECK"
    eip-attached                                            = "EIP_ATTACHED"
    elasticache-redis-cluster-automatic-backup-check        = "ELASTICACHE_REDIS_CLUSTER_AUTOMATIC_BACKUP_CHECK"
    elasticsearch-encrypted-at-rest                         = "ELASTICSEARCH_ENCRYPTED_AT_REST"
    elasticsearch-in-vpc-only                               = "ELASTICSEARCH_IN_VPC_ONLY"
    elb-acm-certificate-required                            = "ELB_ACM_CERTIFICATE_REQUIRED"
    elb-custom-security-policy-ssl-check                    = "ELB_CUSTOM_SECURITY_POLICY_SSL_CHECK"
    elb-deletion-protection-enabled                         = "ELB_DELETION_PROTECTION_ENABLED"
    elb-logging-enabled                                     = "ELB_LOGGING_ENABLED"
    elb-predefined-security-policy-ssl-check                = "ELB_PREDEFINED_SECURITY_POLICY_SSL_CHECK"
    emr-kerberos-enabled                                    = "EMR_KERBEROS_ENABLED"
    emr-master-no-public-ip                                 = "EMR_MASTER_NO_PUBLIC_IP"
    encrypted-volumes                                       = "ENCRYPTED_VOLUMES"
    fms-security-group-audit-policy-check                   = "FMS_SECURITY_GROUP_AUDIT_POLICY_CHECK"
    fms-security-group-content-check                        = "FMS_SECURITY_GROUP_CONTENT_CHECK"
    fms-security-group-resource-association-check           = "FMS_SECURITY_GROUP_RESOURCE_ASSOCIATION_CHECK"  
    fms-shield-resource-policy-check                        = "FMS_SHIELD_RESOURCE_POLICY_CHECK"
    fms-webacl-resource-policy-check                        = "FMS_WEBACL_RESOURCE_POLICY_CHECK"
    fms-webacl-rulegroup-association-check                  = "FMS_WEBACL_RULEGROUP_ASSOCIATION_CHECK"
    guardduty-enabled-centralized                           = "GUARDDUTY_ENABLED_CENTRALIZED"
    guardduty-non-archived-findings                         = "GUARDDUTY_NON_ARCHIVED_FINDINGS"
    iam-password-policy                                     = "IAM_PASSWORD_POLICY"
    iam-group-has-users-check                               = "IAM_GROUP_HAS_USERS_CHECK"
    iam-policy-blacklisted-check                            = "IAM_POLICY_BLACKLISTED_CHECK"
    iam-policy-in-use                                       = "IAM_POLICY_IN_USE"
    iam-policy-no-statements-with-admin-access              = "IAM_POLICY_NO_STATEMENTS_WITH_ADMIN_ACCESS"
    iam-role-managed-policy-check                           = "IAM_ROLE_MANAGED_POLICY_CHECK"
    iam-root-access-key-check                               = "IAM_ROOT_ACCESS_KEY_CHECK"
    iam-user-group-membership-check                         = "IAM_USER_GROUP_MEMBERSHIP_CHECK"
    iam-user-mfa-enabled                                    = "IAM_USER_MFA_ENABLED"
    iam-user-no-policies-check                              = "IAM_USER_NO_POLICIES_CHECK"
    iam-user-unused-credentials-check                       = "IAM_USER_UNUSED_CREDENTIALS_CHECK"
    internet-gateway-authorized-vpc-only                    = "INTERNET_GATEWAY_AUTHORIZED_VPC_ONLY"
    kms-cmk-not-scheduled-for-deletion                      = "KMS_CMK_NOT_SCHEDULED_FOR_DELETION"
    lambda-concurrency-check                                = "LAMBDA_CONCURRENCY_CHECK"
    lambda-dlq-check                                        = "LAMBDA_DLQ_CHECK"
    lambda-function-settings-check                          = "LAMBDA_FUNCTION_SETTINGS_CHECK"
    lambda-function-public-access-prohibited                = "LAMBDA_FUNCTION_PUBLIC_ACCESS_PROHIBITED"
    lambda-inside-vpc                                       = "LAMBDA_INSIDE_VPC"
    mfa-enabled-for-iam-console-access                      = "MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS"
    multi-region-cloud-trail-enabled                        = "MULTI_REGION_CLOUD_TRAIL_ENABLED"
    rds-enhanced-monitoring-enabled                         = "RDS_ENHANCED_MONITORING_ENABLED"
    rds-instance-public-access-check                        = "RDS_INSTANCE_PUBLIC_ACCESS_CHECK"
    rds-multi-az-support                                    = "RDS_MULTI_AZ_SUPPORT"
    rds-snapshots-public-prohibited                         = "RDS_SNAPSHOTS_PUBLIC_PROHIBITED"
    rds-storage-encrypted                                   = "RDS_STORAGE_ENCRYPTED"
    redshift-cluster-configuration-check                    = "REDSHIFT_CLUSTER_CONFIGURATION_CHECK"
    redshift-cluster-maintenancesettings-check              = "REDSHIFT_CLUSTER_MAINTENANCESETTINGS_CHECK"
    redshift-cluster-public-access-check                    = "REDSHIFT_CLUSTER_PUBLIC_ACCESS_CHECK"
    required-tags                                           = "REQUIRED_TAGS"
    restricted-common-ports                                 = "RESTRICTED_INCOMING_TRAFFIC"
    restricted-ssh                                          = "INCOMING_SSH_DISABLED"
    root-account-hardware-mfa-enabled                       = "ROOT_ACCOUNT_HARDWARE_MFA_ENABLED"
    root-account-mfa-enabled                                = "ROOT_ACCOUNT_MFA_ENABLED"
    sagemaker-endpoint-configuration-kms-key-configured     = "SAGEMAKER_ENDPOINT_CONFIGURATION_KMS_KEY_CONFIGURED"
    sagemaker-notebook-no-direct-internet-access            = "SAGEMAKER_NOTEBOOK_NO_DIRECT_INTERNET_ACCESS"
    sagemaker-notebook-kms-configured                       = "SAGEMAKER_NOTEBOOK_INSTANCE_KMS_KEY_CONFIGURED"
    service-vpc-endpoint-enabled                            = "SERVICE_VPC_ENDPOINT_ENABLED"
    shield-advanced-enabled-autorenew                       = "SHIELD_ADVANCED_ENABLED_AUTORENEW"
    shield-drt-access                                       = "SHIELD_DRT_ACCESS"
    s3-account-level-public-access-blocks                   = "S3_ACCOUNT_LEVEL_PUBLIC_ACCESS_BLOCKS"
    s3-blacklisted-actions-prohibited                       = "S3_BLACKLISTED_ACTIONS_PROHIBITED"
    s3-bucket-logging-enabled                               = "S3_BUCKET_LOGGING_ENABLED"
    s3-bucket-policy-grantee-check                          = "S3_BUCKET_POLICY_GRANTEE_CHECK"
    s3-bucket-policy-not-more-permissive                    = "S3_BUCKET_POLICY_NOT_MORE_PERMISSIVE"
    s3-bucket-public-read-prohibited                        = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
    s3-bucket-public-write-prohibited                       = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
    s3-bucket-replication-enabled                           = "S3_BUCKET_REPLICATION_ENABLED"
    s3-bucket-server-side-encryption-enabled                = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
    s3-bucket-ssl-requests-only                             = "S3_BUCKET_SSL_REQUESTS_ONLY"
    s3-bucket-versioning-enabled                            = "S3_BUCKET_VERSIONING_ENABLED"
    vpc-default-security-group-closed                       = "VPC_DEFAULT_SECURITY_GROUP_CLOSED"
    vpc-flow-logs-enabled                                   = "VPC_FLOW_LOGS_ENABLED"
    vpc-sg-open-only-to-authorized-ports                    = "VPC_SG_OPEN_ONLY_TO_AUTHORIZED_PORTS"
    vpc-vpn-2-tunnels-up                                    = "VPC_VPN_2_TUNNELS_UP"
  }
  description = "To be used as reference as key is mapped to a AWS Managed rule. For full lists - https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html"
  type        = map
}

###########################################
##### Config IAM Role 
###########################################
variable "config-sid" {
  description = "Name of SID"
  default = "ConfigRole"
}

variable "config-effect" {
  default = "Allow"
}

variable "config-actions" {
  type        = list
  description = "List of IAM actions to include in policy"
  default     = ["sts:AssumeRole",]
}

variable "config-principal-type" {
  type        = string
  default     = "Service"
}

variable "config-principal-identifier" {
  type        = list
  default     = ["config.amazonaws.com",]
}
