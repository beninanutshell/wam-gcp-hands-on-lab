<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | 2.4.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | 4.76.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.4.0 |
| <a name="provider_google"></a> [google](#provider\_google) | 4.76.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_functions_start"></a> [cloud\_functions\_start](#module\_cloud\_functions\_start) | GoogleCloudPlatform/cloud-functions/google | ~> 0.4 |
| <a name="module_cloud_functions_stop"></a> [cloud\_functions\_stop](#module\_cloud\_functions\_stop) | GoogleCloudPlatform/cloud-functions/google | ~> 0.4 |
| <a name="module_service_account_gce"></a> [service\_account\_gce](#module\_service\_account\_gce) | terraform-google-modules/service-accounts/google | ~> 3.0 |
| <a name="module_service_account_gcf"></a> [service\_account\_gcf](#module\_service\_account\_gcf) | terraform-google-modules/service-accounts/google | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_instance.instance_bco](https://registry.terraform.io/providers/hashicorp/google/4.76.0/docs/resources/compute_instance) | resource |
| [google_project_iam_member.project_run_invoker](https://registry.terraform.io/providers/hashicorp/google/4.76.0/docs/resources/project_iam_member) | resource |
| [google_storage_bucket.bucket](https://registry.terraform.io/providers/hashicorp/google/4.76.0/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_object.function-source-start](https://registry.terraform.io/providers/hashicorp/google/4.76.0/docs/resources/storage_bucket_object) | resource |
| [google_storage_bucket_object.function-source-stop](https://registry.terraform.io/providers/hashicorp/google/4.76.0/docs/resources/storage_bucket_object) | resource |
| [archive_file.start](https://registry.terraform.io/providers/hashicorp/archive/2.4.0/docs/data-sources/file) | data source |
| [archive_file.stop](https://registry.terraform.io/providers/hashicorp/archive/2.4.0/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_function_location"></a> [function\_location](#input\_function\_location) | The location of this cloud function | `string` | n/a | yes |
| <a name="input_members"></a> [members](#input\_members) | Cloud Function Invoker and Developer roles for Users/SAs. Key names must be developers and/or invokers | `map(list(string))` | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID to create Cloud Function | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
